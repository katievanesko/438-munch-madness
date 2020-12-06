//
//  PlayerCollectionViewCell.swift
//  munch-madness
//
//  Created by Katie Vanesko on 12/4/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import UIKit

class PlayerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(title: String) {
           imageView.image = UIImage(systemName: "person.circle.fill")
           label.text = title
       }
    
       static func nib() ->UINib {
           return UINib(nibName: "PlayerCollectionViewCell", bundle: nil)
       }

}
