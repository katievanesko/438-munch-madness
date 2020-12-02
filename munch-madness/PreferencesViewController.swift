//
//  PreferencesViewController.swift
//  munch-madness
//
//  Created by Katie Vanesko on 11/16/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var cuisinePicker: UIPickerView!
    @IBAction func pricePicker(_ sender: Any) {
    }
    @IBOutlet weak var radiusPicker: UIPickerView!
    @IBOutlet weak var findRestaurantsBtn: UIButton!
    @IBOutlet weak var location: UITextView!
    
    
    var cuisineData:[String] = []
    var priceData:[String] = []
    var radiusData:[String] = []
  
    
    //
    var venues: [Restaurant] = []
    
    func retrieveVenues(location : location, category: cuisinePicker, limit : 20, sortBy: "distance", price: pricePicker, radius: radiusPicker) {(response, error); in
        if let response = response {
            self.venues = response
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        cuisineData = ["Any","American","Breakfast","Burgers", "Chinese","Italian", "Japanese","Korean" ,"Mexican","Pizza","Sandwiches","Seafood"]
        radiusData = ["Any", "1 mile","5 miles","10 miles","15 miles"]

        cuisinePicker.dataSource = self
        cuisinePicker.delegate = self
  
        radiusPicker.dataSource = self
        radiusPicker.delegate = self
        
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
   


}
