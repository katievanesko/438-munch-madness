//
//  ViewController.swift
//  munch-madness
//
//  Created by Katie Vanesko on 11/16/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {
    
    var ref: DatabaseReference!

//    var gamePin: NSString?
    var userName: String = ""

    var gameCode: String?
    
    @IBOutlet weak var joinCodeField: UITextField!
    
    @IBAction func joinFieldChanged(_ sender: Any) {
        gameCode = joinCodeField.text
    }
    
    // testing how to add users to an array in the database
    // basically creating a set of users for each group - not quite an array, but similar vibe https://stackoverflow.com/questions/39815117/add-an-item-to-a-list-in-firebase-database
    @IBAction func joinGroupBtn(_ sender: Any) {
        // I moved the contents of addUser() here to check if code exists, and if it does, perform segue
        DispatchQueue.global(qos: .userInitiated).async {
            self.ref.child("groups").observeSingleEvent(of: .value, with: { (snapshot) in
                if let code = self.gameCode {
                    print("code in VC \(code)")
                    if snapshot.hasChild(code) {
                        self.ref.child("groups").child(code).child("users").child("putUserNameHere").setValue(true)

                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }

                        let managedContent = appDelegate.persistentContainer.viewContext

                        if let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContent) {
                            let currentUser = NSManagedObject(entity: entity, insertInto: managedContent)
                            currentUser.setValue("putUserNameHere", forKey: "name")
                            currentUser.setValue(code, forKey: "code")
                            do {
                                try managedContent.save()
                                print("saved \(currentUser)")
                            } catch {
                                print("Could not save")
                            }
                        }
                        DispatchQueue.main.async {
                            let newWaitingVC = self.storyboard?.instantiateViewController(withIdentifier: "WaitingViewController") as! WaitingViewController
                            self.present(newWaitingVC, animated: false, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Group Code Not Found", message: "Please try again!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { alert in }))

                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
    }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.joinCodeField.delegate = self
        ref = Database.database().reference()
        watchGroupData()
        
//        addUser()
//        voteTransactions(groupID: gameCode!)
        // addUser()
    }
//      commented part from https://firebase.google.com/docs/database/ios/read-and-write
    // other part from Lecture 9 video 32:41
    func watchGroupData(){
//        var refHandle = ref.observe(DataEventType.value, with: { (snapshot) in
//          let postDict = snapshot.value as? [String : AnyObject] ?? [:]
//          // ...
//        })
        //this prints what is in the database
        ref.observe(.value, with: {
            snapshot in
            
//            print("\(snapshot.key)-> \(String(describing:snapshot.value))")
        })
    }
    
    // we should move this to somewhere else--maybe WaitingViewController?
//    func addUser() -> Bool {
//        // testing how to add users to an array in the database
//       // basically creating a set of users for each group - not quite an array, but similar vibe https://stackoverflow.com/questions/39815117/add-an-item-to-a-list-in-firebase-database
//
//        var hasChild = false
//        self.ref.child("groups").observe(.value, with: { (snapshot) in
//            if let code = self.gameCode {
//                print("code \(code)")
//                if snapshot.hasChild(code) {
//                    hasChild = true
//                    self.ref.child("groups").child(code).child("users").child("putUserNameHere").setValue(true)
//                }
//            }
//
//        })
//        return hasChild
//    }
    

    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        print("preparing for segue")
//        if let target = segue.destination as? PreferencesViewController {
//
//            target.gameCode = gameCode ?? ""
//        }
//    }

}

