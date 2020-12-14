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

    @IBOutlet weak var timer: UILabel!
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var topName: UILabel!
    
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
    var imageCache: [UIImage] = []
    var startTime: DispatchTime = DispatchTime.now()
    var bottomStays: Bool = false
    
    var currTopVotes: Int = 0
    var currBottomVotes: Int = 0
    var currTopTime: Double = 0.0
    var currBottomTime: Double = 0.0
    var swiped = false
    var timerSeconds: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        // Do any additional setup after loading the view.
        
        //help https://stackoverflow.com/questions/24215117/how-to-recognize-swipe-in-all-4-directions
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(completeSwipe))
        rightSwipe.direction = .right
        rightSwipe.delegate = self
        bottomView.isUserInteractionEnabled = true
        self.bottomView.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(completeSwipe))
        leftSwipe.direction = .left
        leftSwipe.delegate = self
        topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(leftSwipe)
        
        // fillInRestaurants()
        fillInInitial()
        watchValues()
        let seconds = 6.0
        self.startTime = DispatchTime.now()
        timerSeconds = Int(seconds)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        

        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
           self.play()
        }
    }
    
    @objc func updateTimer() {
        timerSeconds -= 1
        timer.text = "\(timerSeconds)"
    }
    
    func play() {
        // Check round number
        let numChoices = self.restaurants.count-1
        if numChoices > 1 {
            // Create new BracketViewController
            let newBracketVC = self.storyboard?.instantiateViewController(withIdentifier: "BracketViewController") as! BracketViewController
            
            self.ref.child("groups").child(self.gameCode).observeSingleEvent(of: .value, with: { (snapshot) in
//                    let groupData = snapshot.value as? NSDictionary
                print(snapshot)
                if self.currTopVotes > self.currBottomVotes{
                     print("in top wins")
                    self.restaurants.remove(at: self.bottomIndex)
                    self.imageCache.remove(at: self.bottomIndex)
                    self.bottomStays = false
                } else if self.currTopVotes < self.currBottomVotes {
                     print("in bottom wins")
                    self.restaurants.remove(at: self.topIndex)
                    self.imageCache.remove(at: self.topIndex)
                    self.bottomStays = true
               } else {
                    if self.currTopTime < self.currBottomTime {
                         print("in top time wins")
                        self.restaurants.remove(at: self.bottomIndex)
                        self.imageCache.remove(at: self.bottomIndex)
                        self.bottomStays = false
                     } else {
                         print("in bottom time wins")
                        self.restaurants.remove(at: self.topIndex)
                        self.imageCache.remove(at: self.topIndex)
                        self.bottomStays = true
                     }
                 }


                newBracketVC.restaurants = self.restaurants
                newBracketVC.gameCode = self.gameCode
                newBracketVC.userName = self.userName
                newBracketVC.imageCache = self.imageCache
                newBracketVC.bottomStays = self.bottomStays
                self.clearVotes()
                print("next round!")
                self.present(newBracketVC, animated: false, completion: nil)
            }) { (error) in
              print(error.localizedDescription)
          }
        }
        else {
            // Move to WinnerVC
            self.ref.child("groups").child(self.gameCode).observeSingleEvent(of: .value, with: { (snapshot) in
                let winnerVC = self.storyboard?.instantiateViewController(withIdentifier: "WinnerViewController") as! WinnerViewController

                if self.currTopVotes > self.currBottomVotes{
                    winnerVC.restaurant = self.restaurants[self.topIndex]
                    winnerVC.passedImage = self.imageCache[self.topIndex]

                } else if self.currTopVotes < self.currBottomVotes {
                    winnerVC.restaurant = self.restaurants[self.bottomIndex]
                    winnerVC.passedImage = self.imageCache[self.bottomIndex]
                } else {
                    if self.currTopTime < self.currBottomTime {
                        winnerVC.restaurant = self.restaurants[self.topIndex]
                        winnerVC.passedImage = self.imageCache[self.topIndex]
                    } else {
                        winnerVC.restaurant = self.restaurants[self.bottomIndex]
                        winnerVC.passedImage = self.imageCache[self.bottomIndex]
                    }
                }
                winnerVC.modalPresentationStyle = .fullScreen
                self.present(winnerVC, animated: true, completion: nil)
              }) { (error) in
                print(error.localizedDescription)
            }

        }
    }
    
    
    @objc func completeSwipe(swipe: UISwipeGestureRecognizer) {
        if swipe.direction == .right {
            print("right swipe")
            if !swiped {
                bottomView.backgroundColor = UIColor.init(named: "GradientTop")
                swiped = true
                voteTransactions(whichRestaurant: "bottom", groupID: gameCode)
            }
        } else if swipe.direction == .left {
            print("left swipe")

            if !swiped {
                topView.backgroundColor = UIColor.init(named: "GradientTop")
                swiped = true
                voteTransactions(whichRestaurant: "top", groupID: gameCode)
            }
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
            if self.bottomStays {
                bottomIndex = 0
                topIndex = 1
                self.bottomStays = false
            }
            topName.text = restaurants[topIndex].name
            topRating.text = String(describing: restaurants[topIndex].rating)
            topCuisine.text! = restaurants[topIndex].categories[0].title
            topImage.image = imageCache[topIndex]

            

            
            bottomName.text = restaurants[bottomIndex].name
            bottomRating.text = String(describing: restaurants[bottomIndex].rating)
            bottomCuisine.text! = restaurants[bottomIndex].categories[0].title
            bottomImage.image = imageCache[bottomIndex]
            
        }
    }
    
    
    //    from https://firebase.google.com/docs/database/ios/read-and-write
        // Basically takes current state and returns new desired state, said helpful for incrementing counts, especially when multiple users may be voting/tapping at once
    func voteTransactions(whichRestaurant: String, groupID: String){
        let nanoVoteTime = DispatchTime.now().uptimeNanoseconds-self.startTime.uptimeNanoseconds
        let secVoteTime = Double(nanoVoteTime) / 1000000000
        
            let voteRef = ref.child("groups").child(groupID)
            voteRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
              if var post = currentData.value as? [String : AnyObject]
              {
                var votes: Dictionary<String, Bool>
                votes = post["votes"] as? [String : Bool] ?? [:]
                var voteCount = 0
                var voteTime = 0.0
                if whichRestaurant == "top" {
                    voteCount = post["topVoteCount"] as? Int ?? 0
                    voteTime = post["topVoteTime"] as? Double ?? 0
                } else {
                    voteCount = post["bottomVoteCount"] as? Int ?? 0
                    voteTime = post["bottomVoteTime"] as? Double ?? 0
                }
                if let _ = votes[self.userName] {
//
                    // DON'T do anything if the user is already there - ie can't re-vote
                    return TransactionResult.success(withValue: currentData)
                } else {
                  // Star the post and add self to stars
                    voteCount += 1
                    votes[self.userName] = true
                    voteTime += secVoteTime
                }
                if whichRestaurant == "top" {
                    post["topVoteCount"] = voteCount as AnyObject?
                    post["topVoteTime"] = voteTime as AnyObject?
                } else {
                    post["bottomVoteCount"] = voteCount as AnyObject?
                    post["bottomVoteTime"] = voteTime as AnyObject?
                }
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
    

    func watchValues() {
        self.ref.child("groups").child(self.gameCode).observe(.value, with: { (snapshot) in
            let groupData = snapshot.value as? NSDictionary
            if let bvc = (groupData?["bottomVoteCount"] as? Int) {
                if bvc>self.currBottomVotes {
                    self.currBottomVotes=bvc
                }
            }
            if let tvc = (groupData?["topVoteCount"] as? Int) {
                if tvc>self.currTopVotes {
                    self.currTopVotes=tvc
                }
            }
            if let bvt = (groupData?["bottomVoteTime"] as? Double) {
                if bvt>self.currBottomTime {
                    self.currBottomTime=bvt
                }
            }
            if let tvt = (groupData?["topVoteTime"] as? Double) {
                if tvt>self.currTopTime {
                    self.currTopTime=tvt
                }
            }
            


        })
    }
    func clearVotes() {
        
        let childUpdates = ["/groups/\(self.gameCode)/topVoteCount": nil,
                            "/groups/\(self.gameCode)/bottomVoteCount": nil, "/groups/\(self.gameCode)/votes": nil, "/groups/\(self.gameCode)/topVoteTime": nil,"/groups/\(self.gameCode)/bottomVoteTime": nil] as [String : Any?]
        self.ref.updateChildValues(childUpdates as [AnyHashable : Any])
    }


}
