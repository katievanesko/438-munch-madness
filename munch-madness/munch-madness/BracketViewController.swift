//
//  BracketViewController.swift
//  munch-madness
//
//  Created by Anda Gavrilescu on 11/21/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import UIKit
import Firebase

class BracketViewController: UIViewController, UIGestureRecognizerDelegate {

//    left swipe
    @IBOutlet weak var topName: UILabel!
//    right swipe
    @IBOutlet weak var bottomName: UILabel!
    
    @IBOutlet weak var topImage: UIImageView!
    
    @IBOutlet weak var bottomImage: UIImageView!
    
    @IBOutlet weak var topRating: UILabel!
    
    @IBOutlet weak var bottomRating: UILabel!
    
    @IBOutlet weak var topCuisine: UILabel!
    
    @IBOutlet weak var bottomCuisine: UILabel!
    
    var restaurants: [Restaurant] = []
    var ref: DatabaseReference!
    var userName: String = "testVoter"
    var gameCode: String = ""
    var topIndex: Int = 0
    var bottomIndex: Int = 1
    var nextIndex: Int = 2

    //add radius/distance and price
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        // Do any additional setup after loading the view.
        
        //help https://stackoverflow.com/questions/24215117/how-to-recognize-swipe-in-all-4-directions
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(completeSwipe))
        rightSwipe.direction = .right
        rightSwipe.delegate = self
        self.view.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(completeSwipe))
        leftSwipe.direction = .left
        leftSwipe.delegate = self
        self.view.addGestureRecognizer(leftSwipe)
        
        // fillInRestaurants()
        fillInInitial()
        
        let seconds = 10.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            // Check round number
            
            let numChoices = self.restaurants.count-1 //set to appropriate value
//            print("NUM CHOICES is \(numChoices)")
            if numChoices > 1 {
                // Create new BracketViewController
                let newBracketVC = self.storyboard?.instantiateViewController(withIdentifier: "BracketViewController") as! BracketViewController
                
                self.ref.child("groups").child(self.gameCode).observeSingleEvent(of: .value, with: { (snapshot) in
                  let groupData = snapshot.value as? NSDictionary
                  let topCount = groupData?["topVoteCount"] as? Int ?? 0
                  let bottomCount = groupData?["bottomVoteCount"] as? Int ?? 0
                  if topCount > bottomCount{
                      self.restaurants.remove(at: self.bottomIndex)

                  } else {
                      self.restaurants.remove(at: self.topIndex)
                  }
//                    print("restaurants after deletion \(self.restaurants)")
                    newBracketVC.restaurants = self.restaurants
                    newBracketVC.gameCode = self.gameCode
                    newBracketVC.userName = self.userName
                    self.clearVotes()
                    print("next round!")
                    self.present(newBracketVC, animated: false, completion: nil)
                  

                }) { (error) in
                  print(error.localizedDescription)
              }
                
                
                
                
            }
            else {
                // Move to WinnerVC
                
                print("winner!")
                
                self.ref.child("groups").child(self.gameCode).observeSingleEvent(of: .value, with: { (snapshot) in
                    let winnerVC = self.storyboard?.instantiateViewController(withIdentifier: "WinnerViewController") as! WinnerViewController
                    let groupData = snapshot.value as? NSDictionary
                    let topCount = groupData?["topVoteCount"] as? Int ?? 0
                    let bottomCount = groupData?["bottomVoteCount"] as? Int ?? 0
//                    print("num of rests = \(self.restaurants.count)")
//                    print("self rest 1 = \(self.restaurants[1])")
                    if topCount > bottomCount{
                        winnerVC.restaurant = self.restaurants[0]
//                        winnerVC.name.text = self.restaurants[0].name
//                        winnerVC.cuisine.text = self.restaurants[0].categories[0].title
//                        winnerVC.rating.text = String(describing: self.restaurants[0].rating)
//                        winnerVC.price.text = self.restaurants[0].price
//                        winnerVC.address.text = self.restaurants[0].location.address1
                    } else {
                        winnerVC.restaurant = self.restaurants[1]
//                        winnerVC.nameText = self.restaurants[1].name
//                        winnerVC.cuisineText = self.restaurants[1].categories[1].title
//                        winnerVC.priceText = self.restaurants[1].price
//                        winnerVC.rating.text = String(describing: self.restaurants[1].rating)
//
//                        winnerVC.name.text = self.restaurants[1].name
//                        winnerVC.cuisine.text = self.restaurants[1].categories[1].title
//                        winnerVC.price.text = self.restaurants[1].price
//                        winnerVC.address.text = self.restaurants[1].location.address1
                    }
                    self.present(winnerVC, animated: true, completion: nil)
                  }) { (error) in
                    print(error.localizedDescription)
                }
                //set all attributes for VC from API
//                winnerVC.image.image =  UIImage(systemName: "pencil")// Change to not that
//                winnerVC.name.text = ""
//                winnerVC.cuisine.text = ""
//                winnerVC.rating.text = ""
//                winnerVC.price.text = ""
//                winnerVC.address.text = ""
                
//                self.present(winnerVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func completeSwipe(swipe: UISwipeGestureRecognizer) {
        if swipe.direction == .right {
            print("right swipe")
            voteTransactions(whichRestaurant: "bottom", groupID: gameCode)
        } else if swipe.direction == .left {
            print("left swipe")
            voteTransactions(whichRestaurant: "top", groupID: gameCode)
        }
    }
    
    //help https://stackoverflow.com/questions/60090877/swipe-gesture-is-not-being-called-on-a-subview-inside-a-present-view-controller
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func fillInInitial(){
        if restaurants.count > 1 {
            topName.text = restaurants[topIndex].name
            topRating.text = String(describing: restaurants[topIndex].rating)
            topCuisine.text! = restaurants[topIndex].categories[0].title

            
            //can have multiple categories, so may want to consider a way to append more than one!
//            for cat in restaurants[0].categories {
//                topCuisine.text! += cat.title + " "
//            }
            
            bottomName.text = restaurants[bottomIndex].name
            bottomRating.text = String(describing: restaurants[bottomIndex].rating)
            bottomCuisine.text! = restaurants[bottomIndex].categories[0].title
//            for cat in restaurants[1].categories {
//                bottomCuisine.text! += cat.title + " "
//            }
           
            
        }
    }
    
    
    //    from https://firebase.google.com/docs/database/ios/read-and-write
        // Basically takes current state and returns new desired state, said helpful for incrementing counts, especially when multiple users may be voting/tapping at once
    func voteTransactions(whichRestaurant: String, groupID: String){
            let voteRef = ref.child("groups").child(groupID)
            voteRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
              if var post = currentData.value as? [String : AnyObject]
    //          , let uid = Auth.auth().currentUser?.uid
              {
                var votes: Dictionary<String, Bool>
                votes = post["votes"] as? [String : Bool] ?? [:]
                var voteCount = 0
                if whichRestaurant == "top" {
                    voteCount = post["topVoteCount"] as? Int ?? 0
                } else {
                    voteCount = post["bottomVoteCount"] as? Int ?? 0
                }
//                var voteCount = post["voteCount"] as? Int ?? 0
                if let _ = votes[self.userName] {
                  // Unstar the post and remove self from stars
                    voteCount -= 1
                    votes.removeValue(forKey: self.userName)
                } else {
                  // Star the post and add self to stars
                  voteCount += 1
                  votes[self.userName] = true
                }
                if whichRestaurant == "top" {
                    post["topVoteCount"] = voteCount as AnyObject?
                } else {
                    post["bottomVoteCount"] = voteCount as AnyObject?
                }
//                post["voteCount"] = voteCount as AnyObject?
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
    
    func checkVotes() -> Bool {
        var result = true
        self.ref.child("groups").child(self.gameCode).observeSingleEvent(of: .value, with: { (snapshot) in
            let groupData = snapshot.value as? NSDictionary
            let topCount = groupData?["topVoteCount"] as? Int ?? 0
            let bottomCount = groupData?["bottomVoteCount"] as? Int ?? 0

            if topCount > bottomCount{
                result = false
            }
            
          }) { (error) in
            print(error.localizedDescription)
        }
        return result
    }
    
    func clearVotes() {
        print("IN CLEAR VOTES")
//        let post = ["topVoteCount": nil, "bottomVoteCount": nil, "votes": nil] as [String : Any?]
        let childUpdates = ["/groups/\(self.gameCode)/topVoteCount": nil,
                            "/groups/\(self.gameCode)/bottomVoteCount": nil, "/groups/\(self.gameCode)/votes": nil] as [String : Any?]
        self.ref.updateChildValues(childUpdates as [AnyHashable : Any])
    }


}
