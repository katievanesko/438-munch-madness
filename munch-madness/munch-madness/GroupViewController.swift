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
    var gamePin: String?
    var restaurants:[Restaurant]=[]
    var prefLoc: String?
    var prefRadius: Int?
    var prefPrice: String?
    var prefCuisine: String?
    
    @IBOutlet weak var codeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // when someone hits "Find Restaurants", the user will be redirected to this VC and group will be created
        ref = Database.database().reference()
        addGroup()
        print("prefPrice is \(prefPrice)")
        addRestaurants()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startPressed(_ sender: Any) {
        if let code = gamePin {
            self.ref.child("groups").child(code).child("isPressed").setValue(true)
        }
    }
    
    func addGroup(){
        gamePin = generatePin(len: 6) as String

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
    
    func addRestaurants(){
//        print("in add restaurants")
//        print(restaurants)
        let frd = FetchRestaurantData()
        DispatchQueue.global(qos: .userInitiated).async {
            frd.retrieveVenues(location: self.prefLoc!, category: self.prefCuisine!, limit: 8, sortBy: "", price: self.prefPrice!, radius: self.prefRadius!){(restList, err) in
                if let error = err {
                    print(error)
                }
                if let restaurantList = restList {
                    self.restaurants = restaurantList
                    for rest in self.restaurants {
                        self.ref.child("groups").child(self.gamePin!).child("restaurants").child(rest.id).setValue(true)
                    }
                }
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
