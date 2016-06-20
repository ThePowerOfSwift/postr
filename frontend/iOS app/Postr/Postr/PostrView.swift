//
//  PostrView.swift
//  Postr
//
//  Created by Steven Kingaby on 07/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit

class PostrView: UIView {
    // Class is used for setting shadows
    // in interface builder
    override func drawRect(rect: CGRect) {
        // Set table view shadow
        self.clipsToBounds = false;
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 5
    }
}
