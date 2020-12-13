//
//  GradientView.swift
//  munch-madness
//
//  Created by Michael Casey on 12/12/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import Foundation
import UIKit

// from https://medium.com/@sakhabaevegor/create-a-color-gradient-on-the-storyboard-18ccfd8158c2

@IBDesignable
class GradientView: UIView {
 @IBInspectable var firstColor: UIColor = UIColor.clear {
   didSet {
       updateView()
    }
 }
 @IBInspectable var secondColor: UIColor = UIColor.clear {
    didSet {
        updateView()
    }
}
    @IBInspectable var isHorizontal: Bool = true {
       didSet {
          updateView()
       }
    }
    
 override class var layerClass: AnyClass {
    get {
       return CAGradientLayer.self
    }
 }
 func updateView() {
     let layer = self.layer as! CAGradientLayer
    layer.colors = [firstColor, secondColor].map{$0.cgColor}
    if (self.isHorizontal) {
       layer.startPoint = CGPoint(x: 0, y: 0.5)
       layer.endPoint = CGPoint (x: 1, y: 0.5)
    } else {
       layer.startPoint = CGPoint(x: 0.5, y: 0)
       layer.endPoint = CGPoint (x: 0.5, y: 1)
    }
}
}
