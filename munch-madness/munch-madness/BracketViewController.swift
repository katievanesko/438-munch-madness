//
//  BracketViewController.swift
//  munch-madness
//
//  Created by Anda Gavrilescu on 11/21/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import UIKit

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
    
    //add radius/distance and price
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            // Check round number
            let numChoices = 1 //set to appropriate value
            if numChoices > 1 {
                // Create new BracketViewController
                let newBracketVC = self.storyboard?.instantiateViewController(withIdentifier: "BracketViewController") as! BracketViewController
                // Set attributes or wait to fill in next viewDidLoad()
                print("next round!")
                self.present(newBracketVC, animated: false, completion: nil)
                
            }
            else {
                // Move to WinnerVC
                print("winner!")
                let winnerVC = self.storyboard?.instantiateViewController(withIdentifier: "WinnerViewController") as! WinnerViewController
                //set all attributes for VC from API
//                winnerVC.image.image =  UIImage(systemName: "pencil")// Change to not that
//                winnerVC.name.text = ""
//                winnerVC.cuisine.text = ""
//                winnerVC.rating.text = ""
//                winnerVC.price.text = ""
//                winnerVC.address.text = ""
                
                self.present(winnerVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func completeSwipe(swipe: UISwipeGestureRecognizer) {
        if swipe.direction == .right {
            print("right swipe")
        } else if swipe.direction == .left {
            print("left swipe")
        }
    }
    
    //help https://stackoverflow.com/questions/60090877/swipe-gesture-is-not-being-called-on-a-subview-inside-a-present-view-controller
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }


}
