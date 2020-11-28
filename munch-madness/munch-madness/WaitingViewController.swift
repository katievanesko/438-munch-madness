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

class WaitingViewController: UIViewController {

    var name = "Guest"
    var ref: DatabaseReference!

    
    @IBOutlet weak var nameField: UITextField!
    
    
    @IBAction func nameFieldChanged(_ sender: Any) {
        if let newName = nameField.text {
            //probably will need to check if the user already has a username and update the field if they do, else create a new entry and update
            // self.ref.child("groups").child(code).child("users").child(name).setValue(true)

            name = newName
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
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
