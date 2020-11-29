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

class WaitingViewController: UIViewController, UITextFieldDelegate {

    var name: String?
    var ref: DatabaseReference!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBAction func nameFieldChanged(_ sender: Any) {
        if let newName = nameField.text {
            name = newName
        }
    }
    
    @IBAction func enterPressed(_ sender: Any) {
        addNewName()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        nameField.delegate = self
    }
    
    func getNameAndCode() -> Array<String> {
        var answers:Array<String> = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return answers
        }

        let managedContent = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")

        do {
            let results = try managedContent.fetch(fetchRequest)
            answers.append(results[0].value(forKey: "name") as! String)
            answers.append(results[0].value(forKey: "code") as! String)
            return answers
        } catch {
            print("Could not fetch")
            return answers
        }
    }
    
    //this all works
    func addNewName() {
        let results = getNameAndCode()
        let oldName = results[0]
        let code = results[1]
        print("old name \(oldName)")
        
        if results.count == 2 {
            if let newName = self.name {
//                DispatchQueue.global(qos: .userInitiated).async {
                    self.ref.child("groups").child(code).child("users").child(oldName).removeValue(completionBlock: { (error, ref) in
                        print(error ?? "success")
                    })
                    
                    self.ref.child("groups").child(code).child("users").child(newName).setValue(true)
                
//                    DispatchQueue.main.async {
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }

                        let managedContent = appDelegate.persistentContainer.viewContext

                        if let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContent) {
                            let currentUser = NSManagedObject(entity: entity, insertInto: managedContent)
                            currentUser.setValue(newName, forKey: "name")

                            do {
                                try managedContent.save()
                            } catch {
                                print("Could not save")
                            }
                        }
//                    }
//                }
            }
        }
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
