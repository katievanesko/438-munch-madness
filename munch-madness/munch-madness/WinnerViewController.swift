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
    var passedImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = restaurant?.name
        cuisine.text = restaurant?.categories[0].title
        rating.text = String(describing: restaurant?.rating)
        address.text = restaurant?.location.address1
        price.text = restaurant?.price
        image.image = passedImage
        
        
        // Do any additional setup after loading the view.
        print("we have a winner")
    }
    
    @IBAction func callRestaurant(_ sender: Any) {
        // Get rest. # from API
        guard let numberFromAPI = restaurant?.phone else {return}
        let arrNumber = Array(numberFromAPI)
        let editedNum = String(arrNumber[2..<12])
        print("editedNum is \(editedNum)")
        
        if let phoneCallURL = URL(string: "tel://\(editedNum)") {
          let application:UIApplication = UIApplication.shared
          if (application.canOpenURL(phoneCallURL)) {
              application.open(phoneCallURL, options: [:], completionHandler: nil)
          }
        }
    }
    
    
    @IBAction func visitWebsite(_ sender: Any) {
        // Get rest. website from API
        guard let restUrl = restaurant?.url else {return}
        
        // Create new VC with webview
        let websiteVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        websiteVC.url = restUrl
        
        self.present(websiteVC, animated: true, completion:  nil)
    }
    
    @IBAction func returnToStart(_ sender: Any) {
        let startVC = self.storyboard?.instantiateViewController(withIdentifier: "StartViewController") as! ViewController
        startVC.modalPresentationStyle = .fullScreen
        self.present(startVC, animated: true, completion: nil)
    }
}
