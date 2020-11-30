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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("we have a winner")
    }
    
    
    @IBAction func callRestaurant(_ sender: Any) {
        // Get rest. # from API
        var rawNum = "+1314NumberFromAPI"
        
        // Remove "+1" from num
        
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
        websiteVC.url = "URL FEOM API"
        
        // Segue to WebsiteVC
        navigationController?.pushViewController(websiteVC,
        animated: true)
    }
    
}
