//
//  WinnerViewController.swift
//  munch-madness
//
//  Created by Katie Vanesko on 11/28/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import UIKit
import WebKit

class WinnerViewController: UIViewController {
    
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var cuisine: UILabel!
    
    @IBOutlet weak var rating: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var callBtn: UIButton!
    
    @IBOutlet weak var websiteBtn: UIButton!
    
    var nameText: String = ""
    var cuisineText: String = ""
    var ratingText: String = ""
    var priceText: String = ""
    
    var restaurant: Restaurant?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = restaurant?.name
        cuisine.text = restaurant?.categories[0].title
        rating.text = String(describing: restaurant?.rating)
        address.text = restaurant?.location.address1
        
        
        // Do any additional setup after loading the view.
        print("we have a winner")
    }
    
    
    @IBAction func callRestaurant(_ sender: Any) {
        // Get rest. # from API
        guard let numberFromAPI = restaurant?.phone else {return}
        var rawNum = numberFromAPI
        
        // Remove "+1" from num
//        if rawNum.contains("+1") {
//            let index = rawNum.firstIndex(of: "+1")!
//            
//        }
        
        guard let number = URL(string: "tel://" + rawNum) else { return }
        UIApplication.shared.open(number)
    }
    
    
    @IBAction func visitWebsite(_ sender: Any) {
        // Get rest. website from API
//        guard let url = URL(string: "URL FROM API") else {
//            print("Could not access website url")
//            return
//        }
        // Create new VC with webview
        let websiteVC = WebViewController()
        guard let restUrl = restaurant?.url else {return}
        websiteVC.url = restUrl
        
        // Segue to WebsiteVC
        navigationController?.pushViewController(websiteVC,
        animated: true)
    }
    
}
