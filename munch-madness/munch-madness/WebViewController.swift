//
//  WebViewController.swift
//  munch-madness
//
//  Created by Katie Vanesko on 11/28/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var url:String?
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        webView.load(NSURLRequest(url: NSURL(string: url ?? "")! as URL) as URLRequest)  //Update "" to redirect to error page or something 
    }
    

}
