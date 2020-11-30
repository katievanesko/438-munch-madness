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
            let numChoices = 10 //set to appropriate value
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
            retrieveVenues(location: "NYC", category: "burgers", limit: 8, sortBy: "review_count", price: "2")
        } else if swipe.direction == .left {
            print("left swipe")
        }
    }
    
        func retrieveVenues(location : String, category: String, limit : Int, sortBy: String, price: String) {
    //        ,completionHandler: @escaping ([Restaurant]?, Error?) -> Void){
            
            
            //Retrieve Restaurants from Yelp API
            let apikey = "UG6WNfp3Lfp2qjXsx57mt7nFVQvUFlBJ3srqmm5JswKRZA14fQXtSc_EW73pa-n7DSmBehNHRBQtdFjKzODYG1OblRtN86hCCis6Q4-5ljCRM51uGyQ2GPMQMvG6X3Yx"
            
            //Create URL
            let baseURL = "https://api.yelp.com/v3/businesses/search?location=\(location)&categories=\(category)&limit=\(limit)&sort_by=\(sortBy)&price=\(price)"
            
            let url = URL(string : baseURL)
        
            
            //create request
            var request = URLRequest(url: url!)
            request.setValue("Bearer\(apikey)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            //initialize session and task
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error{
                    print(error)
    //                completionHandler(nil, error)
                }
                do {
                    //Read data as JSON
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    
                    //main dictionary
                    guard let response = json as? NSDictionary else {return}
                    
                    //Businesses
                    guard let businesses = response.value(forKey: "businesses") as? [NSDictionary] else {return}
                    
                    var restaurantList: [Restaurant] = []
                    
                    //accessing venue information
                    for business in businesses {
                        var restaurant = Restaurant()
                        restaurant.name = business.value(forKey: "name") as? String
                        restaurant.id = business.value(forKey: "id") as? String
                        restaurant.rating = business.value(forKey: "rating") as? Float
                        restaurant.price = business.value(forKey: "price") as? String
                        restaurant.distance = business.value(forKey: "distance") as? Double
                        let address = business.value(forKeyPath: "location.display_address") as? [String]
                        restaurant.address = address?.joined(separator: "\n")
                        
                        restaurantList.append(restaurant)
                    }
                    print(restaurantList)
    //                completionHandler(restaurantList, nil)
                    
                }
                catch{
                    print("Caught error")
                }
            }
            .resume()
        }
    
    
    
    
    //help https://stackoverflow.com/questions/60090877/swipe-gesture-is-not-being-called-on-a-subview-inside-a-present-view-controller
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }


}
