//
//  GroupViewController.swift
//  munch-madness
//
//  Created by Anda Gavrilescu on 11/25/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import CoreData

class GroupViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var name: String?
    var ref: DatabaseReference!
    var gamePin: String?
    var restaurants:[Restaurant] = []
    var prefLoc: String?
    var prefRadius: Int?
    var prefPrice: String?
    var prefCuisine: String?
    var currentPlayersList:[String] = []
    var imageCache: [UIImage] = []
    
    @IBOutlet weak var codeLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var currentPlayerCollectionView: UICollectionView!
    
    @IBOutlet weak var nameStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // when someone hits "Find Restaurants", the user will be redirected to this VC and group will be created
        print("CURRENT USERS: \(currentPlayersList)")
        
        ref = Database.database().reference()
        nameTextField.delegate = self
        currentPlayerCollectionView.delegate = self
        currentPlayerCollectionView.dataSource = self
        currentPlayerCollectionView.register(PlayerCollectionViewCell.nib(), forCellWithReuseIdentifier: "PlayerCollectionViewCell")
               
        
        addGroup()
//        print("prefPrice is \(prefPrice)")
        addRestaurants()
        addNewName()
    }
    
    @IBAction func startPressed(_ sender: Any) {
        if let code = gamePin {
            self.ref.child("groups").child(code).child("isPressed").setValue(true)
        }
    }
    
    func addGroup(){
        gamePin = generatePin(len: 6) as String

        codeLabel.text = gamePin as String?
        
        self.ref.child("groups").child(gamePin!).child("users").child("Host").setValue(true)
        self.ref.child("groups").child(gamePin!).child("usersCount").setValue(1)

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContent = appDelegate.persistentContainer.viewContext
        if let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContent) {
            let currentUser = NSManagedObject(entity: entity, insertInto: managedContent)
            currentUser.setValue("Host", forKey: "name")
            currentUser.setValue(gamePin!, forKey: "code")
            do {
                try managedContent.save()
                print("saved \(currentUser)")
            } catch {
                print("Could not save")
            }
        }
        
        //WATCH FOR CHILDREN ADDED
        self.ref.child("groups").child(gamePin ?? "").child("users").observe(.childAdded, with: { (snapshot) in
            print("snapshot key \(snapshot.key) in GroupVC")
            if !self.currentPlayersList.contains(snapshot.key){
                self.currentPlayersList.append(snapshot.key)
                
                DispatchQueue.main.async {
                    self.currentPlayerCollectionView.reloadData()
                }
            }
        })
        
        //WATCH FOR CHILDREN DELETED
        self.ref.child("groups").child(gamePin ?? "").child("users").observe(.childRemoved, with: { (snapshot) in
            print("removing \(snapshot.key) in GroupVC")
            if let index = self.currentPlayersList.firstIndex(of: snapshot.key){
                 self.currentPlayersList.remove(at: index)
            }
        
            DispatchQueue.main.async {
                self.currentPlayerCollectionView.reloadData()
            }
        })
    }
    
    // based on solution 1 from https://izziswift.com/short-random-unique-alphanumeric-keys-similar-to-youtube-ids-in-swift/
    // generates a random alphanumeric Pin for the game of length len
    func generatePin(len: Int) -> NSString{
    
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for _ in 1...len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return randomString
    }
    
    func addRestaurants(){
//        print("in add restaurants")
//        print(restaurants)
        let frd = FetchRestaurantData()
        DispatchQueue.global(qos: .userInitiated).async {
            

            self.ref.child("groups").child(self.gamePin!).child("query").child("price").setValue(self.prefPrice!)
            self.ref.child("groups").child(self.gamePin!).child("query").child("location").setValue(self.prefLoc!)
            self.ref.child("groups").child(self.gamePin!).child("query").child("radius").setValue(self.prefRadius!)
            self.ref.child("groups").child(self.gamePin!).child("query").child("cuisine").setValue(self.prefCuisine!)

                  
            frd.retrieveVenues(location: self.prefLoc!, category: self.prefCuisine!, limit: 8, sortBy: "", price: self.prefPrice!, radius: self.prefRadius!){(restList, err) in
                if let error = err {
                    print(error)
                }
                if let restaurantList = restList {
                    if restaurantList.count == 0 {
                        DispatchQueue.main.async {
                            //ALERT THAT NO RESTAURANTS EXIST
                            let alertController = UIAlertController(title: "No restaurants found for given parameters", message: "Please adjust search parameters", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
                                //SEND BACK TO PREFERENCESVC
                                self.presentingViewController?.dismiss(animated: true, completion: nil)
                            })
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    self.restaurants = restaurantList
                    let nullImg = UIImage(named: "NullPoster")
                    var count = 0
                    for rest in self.restaurants {
                        print("rest #\(count)")
                        count = count + 1
                        self.ref.child("groups").child(self.gamePin!).child("restaurants").child(rest.id).setValue(true)
                        
                        if let imagePath = rest.image_url{
                            let url = URL(string:imagePath)
                            
                            if let data = try? Data(contentsOf: url!){
                                if let image = UIImage(data: data) {
                                    self.imageCache.append(image)
                                    print ("image added")
                                } else {
                                    self.imageCache.append(nullImg!)
                                    print("null poster added")
                                }
                            } else {
                                self.imageCache.append(nullImg!)
                                print("null poster added")
                            }
                        } else {
                            self.imageCache.append(nullImg!)
                            print("null poster added")
                        }
                        
// if we try to store all data on firebase, would try here
//                        self.ref.child("groups").child(self.gamePin!).child("restaurants").child(rest.id).setValue(rest)
                    }

                }
            }
        }
    }
    
    
    @IBAction func copyCode(_ sender: Any) {
        UIPasteboard.general.string = codeLabel.text
    }
    
    @IBAction func addHostName(_ sender: Any) {
        print("CURRENT USERS: \(currentPlayersList)// ADDHOSTNAME()")
        self.name = self.nameTextField.text
        addNewName()
        DispatchQueue.main.async {
            self.currentPlayerCollectionView.reloadData()
        }
    }
    
    func getNameAndCode() -> Array<String> {
        var answers:Array<String> = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }

        let managedContent = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")

        do {
            let results = try managedContent.fetch(fetchRequest)
//            print(results)
            answers.append(results[results.count - 1].value(forKey: "name") as! String)
            answers.append(results[results.count - 1].value(forKey: "code") as! String)
            return answers
        } catch {
            print("Could not fetch")
            return []
        }
    }
    
    func addNewName() {
        let results = getNameAndCode()
        let oldName = results[0]
        let code = results[1]
        
        if results.count == 2 {
            if let newName = self.name {
                if !self.currentPlayersList.contains(newName){
                    print("Current list: \(self.currentPlayersList)")
                    print(newName)
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.ref.child("groups").child(code).child("users").child(oldName).removeValue(completionBlock: { (error, ref) in
                            print(error ?? "success")
                        })
                        self.ref.child("groups").child(code).child("users").child(newName).setValue(true)
                        
                        DispatchQueue.main.async {
                            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                return
                            }
                            let managedContent = appDelegate.persistentContainer.viewContext
                            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
                            fetchRequest.predicate = NSPredicate(format: "code = %@", code)
                            
                            do {
                                let results = try managedContent.fetch(fetchRequest)
                                if results.count > 0 {
                                    let object = results[0]
                                    object.setValue(self.name, forKey: "name")
                                    do {
                                        try managedContent.save()
                                        self.nameStack.removeFromSuperview()
//                                        self.currentPlayersList.append(self.name ?? "Player")
                                    } catch {
                                        print("Could not save")
                                    }
                                }
                            } catch {
                                print("Could not fetch")
                            }
                        }
                    }
                } else {
                    print("Alert should show up")
                    let alertController = UIAlertController(title: "Name Already Exists", message: "Please choose another name", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    self.nameTextField.text = ""
                }
                DispatchQueue.main.async {
                    self.currentPlayerCollectionView.reloadData()
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.currentPlayersList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCollectionViewCell", for: indexPath) as! PlayerCollectionViewCell
        cell.configure(title: currentPlayersList[indexPath.row])
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let target = segue.destination as? BracketViewController {
            target.restaurants = self.restaurants
            target.gameCode = self.gamePin ?? ""
            target.imageCache = self.imageCache
        }
    }
    

    
}
