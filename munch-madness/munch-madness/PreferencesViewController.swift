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

class PreferencesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
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
    
    var ref: DatabaseReference!
    var restaurants:[Restaurant] = []
    
    
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
    
    
    @IBAction func findRestaurants(_ sender: Any) {
//        print("in find restaurants")
//        let frd = FetchRestaurantData()
//        let loc = location.text ?? ""
//        let p = priceInNumbers[ price.selectedSegmentIndex]
////        let r = radiusInMeters[radiusPicker.selectedRow(inComponent: 1)]
//        let c = cuisineData[cuisinePicker.selectedRow(inComponent: 0)]
//
      
        
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
//            print("preparing for segue")
            if let target = segue.destination as? GroupViewController {
                target.prefLoc = location.text ?? ""
                target.prefPrice = priceInNumbers[ price.selectedSegmentIndex]
                target.prefRadius=radiusInMeters[radiusPicker.selectedRow(inComponent: 0)]
                target.prefCuisine = cuisineData[cuisinePicker.selectedRow(inComponent: 0)]
                        

                
            }
        }
    


}
