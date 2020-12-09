//
//  WaitingViewController.swift
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

class WaitingViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource{


    var name: String?
    var ref: DatabaseReference!
    var currentPlayersList:[String] = []
    var gameCode: String?
    var restaurants: [Restaurant] = []
//    var userName: String = "guest"
    
    @IBOutlet weak var nameStack: UIStackView!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var currentPlayerCollectionView: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        self.spinner.hidesWhenStopped = true
        nameField.delegate = self
        currentPlayerCollectionView.delegate = self
        currentPlayerCollectionView.dataSource = self
        currentPlayerCollectionView.register(PlayerCollectionViewCell.nib(), forCellWithReuseIdentifier: "PlayerCollectionViewCell")
        name = generateGuestUsername(len: 4)
        addNewName()
        getRestaurants()
        checkStartPressed()
        checkCurrentPlayers()
    }
    
    @IBAction func nameFieldChanged(_ sender: Any) {
        self.spinner.startAnimating()
        if let newName = nameField.text {
            //probably will need to check if the user already has a username and update the field if they do, else create a new entry and update
            // self.ref.child("groups").child(code).child("users").child(name).setValue(true)

            name = newName
        }
    }
    
    @IBAction func enterPressed(_ sender: Any) {
        addNewName()
    }
    
    func checkStartPressed() {
        let results = getNameAndCode()
        let code = results[1]
        self.ref.child("groups").child(code).child("isPressed").observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                let newBracketVC = self.storyboard?.instantiateViewController(withIdentifier: "BracketViewController") as! BracketViewController
                
                newBracketVC.restaurants = self.restaurants
                newBracketVC.userName = self.name ?? "guest"
                
                guard let gc = self.gameCode else { return }
                newBracketVC.gameCode = gc
                self.present(newBracketVC, animated: false, completion: nil)
            }
        })
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
            print(results)
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
                                } catch {
                                    print("Could not save")
                                }
                            }
                        } catch {
                            print("Could not fetch")
                        }
                    }
                }
            }
        }
    }
    
    func checkCurrentPlayers() {
        let results = getNameAndCode()
        let code = results[1]
        
        self.ref.child("groups").child(code).child("users").observe(.value, with: { (snapshot) in
                print("HERE")
                guard let snapChildren = snapshot.value as? [String: Any] else { return }
                for snap in snapChildren {
                    print(snap.key)
                    self.currentPlayersList.append(snap.key)
                }
            
            
            DispatchQueue.main.async {
                self.currentPlayerCollectionView.reloadData()
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.currentPlayersList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCollectionViewCell", for: indexPath) as! PlayerCollectionViewCell
        cell.configure(title: currentPlayersList[indexPath.row])
        return cell
    }
    
    
    func getRestaurants(){
            let frd = FetchRestaurantData()
            DispatchQueue.global(qos: .userInitiated).async {
                self.ref.child("groups").child(self.gameCode!).child("query").observeSingleEvent(of: .value, with: { (snapshot) in
                    let queryData = snapshot.value as? NSDictionary
                    guard let qd = queryData else { return }
                    let price = qd["price"] as! String
                    let cuisine = qd["cuisine"] as! String
                    let radius = qd["radius"] as! Int
                    let location = qd["location"] as! String
                    frd.retrieveVenues(location: location, category: cuisine, limit: 8, sortBy: "", price: price, radius: radius){(restList, err) in
                        if let error = err {
                            print(error)
                        }
                        if let restaurantList = restList {
                            self.restaurants = restaurantList
                        }
                        
                    }
                    

                  }) { (error) in
                    print(error.localizedDescription)
                }

            }
        }
    
    func generateGuestUsername(len: Int) -> String{
    
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for _ in 1...len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return ("guest_" + (randomString as String)) as String
    }
    
    // MARK: - Navigation

//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        if let target = segue.destination as? BracketViewController {
//            target.restaurants = self.restaurants
//
//            guard let gc = self.gameCode else { return }
//            target.gameCode = gc
//        }
//    }
    
}
