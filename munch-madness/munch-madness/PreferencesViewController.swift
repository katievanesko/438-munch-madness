//
//  PreferencesViewController.swift
//  munch-madness
//
//  Created by Katie Vanesko on 11/16/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MapKit
import CoreLocation

class PreferencesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate{
    
    
    @IBOutlet weak var cuisinePicker: UIPickerView!
    @IBAction func pricePicker(_ sender: Any) {
    }
    @IBOutlet weak var radiusPicker: UIPickerView!
    @IBOutlet weak var findRestaurantsBtn: UIButton!
    @IBOutlet weak var location: UITextView!
    
    @IBOutlet weak var price: UISegmentedControl!
    
    var gameCode: String = ""
    var cuisineData:[String] = []
    var priceData:[String] = []
    var radiusData:[String] = []
    
    var radiusInMeters = [40000, 1600, 8000, 16000, 24000]
    var priceInNumbers = ["1,2,3,4","1", "2", "3","4"]
    var cuisineForURL = ["any","tradamerican","breakfast_brunch","burgers", "chinese","italian", "japanese","korean" ,"mexican","pizza","sandwiches","seafood"]
    
    var ref: DatabaseReference!
    var restaurants:[Restaurant] = []
    
    let locationManager = CLLocationManager()
    var currentZipcode:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("game code is \(gameCode)")
        
        cuisineData = ["Any","American","Breakfast","Burgers", "Chinese","Italian", "Japanese","Korean" ,"Mexican","Pizza","Sandwiches","Seafood"]
        radiusData = ["Any", "1 mile","5 miles","10 miles","15 miles"]

        cuisinePicker.dataSource = self
        cuisinePicker.delegate = self
  
        radiusPicker.dataSource = self
        radiusPicker.delegate = self
        ref = Database.database().reference()

        getLocation()
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return cuisineData.count
        } else {
            return radiusData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return cuisineData[row]
        } else {
            return radiusData[row]
        }
    }
    
    func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in

            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }

            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0]
                
                if let containsPlacemark = pm {
                    self.locationManager.stopUpdatingLocation()
                    self.currentZipcode = ((containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : "") ?? ""
                    self.location.text = self.currentZipcode
                }
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    

    
    @IBAction func findRestaurants(_ sender: Any) {
//        print("in find restaurants")
//        let frd = FetchRestaurantData()
//        let loc = location.text ?? ""
//        let p = priceInNumbers[ price.selectedSegmentIndex]
////        let r = radiusInMeters[radiusPicker.selectedRow(inComponent: 1)]
//        let c = cuisineData[cuisinePicker.selectedRow(inComponent: 0)]
//
      
        
    }
    
    func checkForPunctuation(_ location: String) -> String {
        var newLocation = ""
        for c in location {
            if c == " " {
                newLocation += "%20"
            } else if c.isLetter || c.isNumber {
                newLocation += String(c)
            } else {
                newLocation += ""
            }
        }
        return newLocation
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
//            print("preparing for segue")
            if let target = segue.destination as? GroupViewController {
                target.prefLoc = checkForPunctuation(location.text ?? "")
                target.prefPrice = priceInNumbers[ price.selectedSegmentIndex]
                target.prefRadius=radiusInMeters[radiusPicker.selectedRow(inComponent: 0)]
                target.prefCuisine = cuisineForURL[cuisinePicker.selectedRow(inComponent: 0)]
                        

                
            }
        }
    


}
