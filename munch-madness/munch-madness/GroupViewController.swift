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

class GroupViewController: UIViewController {

    var ref: DatabaseReference!
    var gamePin: NSString?
    
    @IBOutlet weak var codeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // when someone hits "Find Restaurants", the user will be redirected to this VC and group will be created
        ref = Database.database().reference()
        addGroup()
        
        // Do any additional setup after loading the view.
    }
    
    func addGroup(){
        gamePin = generatePin(len: 6)
        self.ref.child("groups").child(gamePin! as String).setValue(["name": "test"])
        codeLabel.text = gamePin as String?
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
