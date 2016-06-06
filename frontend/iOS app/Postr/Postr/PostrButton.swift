//
//  PostrButton.swift
//  Postr
//
//  Created by Steven Kingaby on 02/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit


// TODO: Rewrite this - taken from stack overflow
class PostrButton: UIButton {
    
    // Corner radius of the background rectangle
    var roundRectCornerRadius: CGFloat = 2

    // Color of the background rectangle
    var roundRectColor: UIColor = UIColor(red:1.00, green:0.60, blue:0.00, alpha:1.0)

    override func layoutSubviews() {
        super.layoutSubviews()
        configurePostrButton()
    }


    // MARK: Private

    var roundRectLayer: CAShapeLayer?

    func configurePostrButton() {
        
        // Change button font family and font color
        self.titleLabel!.font = UIFont(name: "coolvetica", size: 15)
        self.titleLabel!.textColor = UIColor.whiteColor()
        
        // Set button shadow
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 5
        
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).CGPath
        shapeLayer.fillColor = roundRectColor.CGColor
        self.layer.insertSublayer(shapeLayer, atIndex: 0)
        self.roundRectLayer = shapeLayer
    }
}
