//
//  FetchRestaurantData.swift
//  munch-madness
//
//  Created by Tristan Senkowski on 11/22/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import Foundation

// helpful documentation https://medium.com/@khansaryan/yelp-fusion-api-integration-af50dd186a6e

//extension ViewController {
class FetchRestaurantData {
    
//    func retrieveVenues(location : String, category: String, limit : Int, sortBy: String, price: String, completionHandler: @escaping ([Restaurant]?, Error?) -> Void){
    func retrieveVenues(location : String, category: String, limit : Int, sortBy: String, price: String) -> [Restaurant]{
        
        
        //Retrieve Restaurants from Yelp API
        let apikey = "UG6WNfp3Lfp2qjXsx57mt7nFVQvUFlBJ3srqmm5JswKRZA14fQXtSc_EW73pa-n7DSmBehNHRBQtdFjKzODYG1OblRtN86hCCis6Q4-5ljCRM51uGyQ2GPMQMvG6X3Yx"
        
        //Create URL
//        let baseURL = "https://api.yelp.com/v3/businesses/search?location=\(location)&categories=\(category)&limit=\(limit)&sort_by=\(sortBy)&price=\(price)"
        let baseURL = "https://api.yelp.com/v3/businesses/search?location=NYC&categories=pizza&limit=5&price=2"
        
        let url = URL(string : baseURL)
        var restaurantList: [Restaurant] = []
        //create request
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        //initialize session and task
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error{
                print(error)
            }
            if let data = data {
                
                do {

                    
                    // Using Decodable structs found in Restaurant.swift
                    let apiResults =  try JSONDecoder().decode(YelpAPIResult.self, from:data)
                    print(apiResults)
                    
                    // Businesses
                    restaurantList = apiResults.businesses
                    
        
                                
                }
                catch{
                    print(error)
                }
            }
            

        }
        .resume()
        return restaurantList
    }
}
