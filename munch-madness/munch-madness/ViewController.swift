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

class ViewController: UIViewController {
    
    var ref: DatabaseReference!
    var gamePin: NSString?


    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        watchGroupData()
        addUser()
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
        ref.observe(.value, with: {
            snapshot in
            
            print("\(snapshot.key)-> \(String(describing:snapshot.value))")
        })
    }
    
    func addGroup(){
        gamePin = generatePin(len: 6)
        self.ref.child("groups").child(gamePin! as String).setValue(["name": "test"])

        
    }
    
    func addUser(){
        // testing how to add users to an array in the database
       // basically creating a set of users for each group - not quite an array, but similar vibe https://stackoverflow.com/questions/39815117/add-an-item-to-a-list-in-firebase-database
        self.ref.child("groups").child("123456").child("users").child("putUserNameHere").setValue(true)

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
    
//    from https://firebase.google.com/docs/database/ios/read-and-write
    // Basically takes current state and returns new desired state, said helpful for incrementing counts, especially when multiple users may be voting/tapping at once
    func voteTransactions(){
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
          if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
            var stars: Dictionary<String, Bool>
            stars = post["stars"] as? [String : Bool] ?? [:]
            var starCount = post["starCount"] as? Int ?? 0
            if let _ = stars[uid] {
              // Unstar the post and remove self from stars
              starCount -= 1
              stars.removeValue(forKey: uid)
            } else {
              // Star the post and add self to stars
              starCount += 1
              stars[uid] = true
            }
            post["starCount"] = starCount as AnyObject?
            post["stars"] = stars as AnyObject?

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

