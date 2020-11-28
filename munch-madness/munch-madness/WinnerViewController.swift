//
//  WinnerViewController.swift
//  munch-madness
//
//  Created by Katie Vanesko on 11/28/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import UIKit

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

        //Load API info into labels
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func callRestaurant(_ sender: Any) {
        
    }
    
    @IBAction func visitWebsite(_ sender: Any) {
        
    }
    
}
