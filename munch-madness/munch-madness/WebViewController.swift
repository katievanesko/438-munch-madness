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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let webView = WKWebView(frame: view.frame)
        webView.load(NSURLRequest(url: NSURL(string: url ?? "")! as URL) as URLRequest)  //Update "" to redirect to error page or something
        
        
    }
    

}
