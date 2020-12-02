//
//  FetchRestaurantData.swift
//  munch-madness
//
//  Created by Tristan Senkowski on 11/22/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import Foundation

// helpful documentation https://medium.com/@khansaryan/yelp-fusion-api-integration-af50dd186a6e

extension ViewController {
    
    func retrieveVenues(location : String, category: String, limit : Int, sortBy: String, price: String, completionHandler: @escaping ([Restaurant]?, Error?) -> Void){
        
        
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
                completionHandler(nil, error)
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
                
                completionHandler(restaurantList, nil)
                
            }
            catch{
                print("Caught error")
            }
        }
        .resume()
    }
}
