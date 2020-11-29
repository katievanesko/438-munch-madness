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
            self.ref.child("groups").observe(.value, with: { (snapshot) in
                if let code = self.gameCode {
                    if snapshot.hasChild(code) {
//                       Going to move this code to Waiting View Controller so that when alter username, adds to database self.ref.child("groups").child(code).child("users").child("putUserNameHere").setValue(true)
                        DispatchQueue.main.async {
                            // should pass the game code to the waiting VC right?
                            self.performSegue(withIdentifier: "toWaitingVC", sender: nil)
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
//        voteTransactions()
//        addGroup()
//        addGroup()

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
            
            print("\(snapshot.key)-> \(String(describing:snapshot.value))")
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
    
//    from https://firebase.google.com/docs/database/ios/read-and-write
    // Basically takes current state and returns new desired state, said helpful for incrementing counts, especially when multiple users may be voting/tapping at once
    func voteTransactions(groupID: String){
        let voteRef = ref.child("groups").child(groupID)
        voteRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
          if var post = currentData.value as? [String : AnyObject]
//          , let uid = Auth.auth().currentUser?.uid
          {
            var votes: Dictionary<String, Bool>
            votes = post["votes"] as? [String : Bool] ?? [:]
            var voteCount = post["voteCount"] as? Int ?? 0
            if let _ = votes[self.userName] {
              // Unstar the post and remove self from stars
                voteCount -= 1
                votes.removeValue(forKey: self.userName)
            } else {
              // Star the post and add self to stars
              voteCount += 1
              votes[self.userName] = true
            }
            post["voteCount"] = voteCount as AnyObject?
            post["votes"] = votes as AnyObject?

            // Set value and report transaction success
            currentData.value = post

            return TransactionResult.success(withValue: currentData)
          }
          return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
          if let error = error {
            print(error.localizedDescription)
          }
        }
    }
    


}

