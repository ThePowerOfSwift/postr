//
//  PostrButton.swift
//  Postr
//
//  Created by Steven Kingaby on 02/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit

class PostrButton: UIButton {
    
    // Corner radius of the background rectangle
    var cornerRadius: CGFloat = 2
    
    // Background colour of rectangle
    var rectangleColor: UIColor = UIColor(red:1.00, green:0.60, blue:0.00, alpha:1.0)
    
    var roundRectLayer: CAShapeLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        configurePostrButton()
    }

    func configurePostrButton() {
        // Change button font family and font color
        self.titleLabel!.font = UIFont(name: "coolvetica", size: 18)
        self.titleLabel!.textColor = UIColor.whiteColor()
        
        // Set button shadow
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 5
        
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        
        // 
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).CGPath
        shapeLayer.fillColor = rectangleColor.CGColor
        self.layer.insertSublayer(shapeLayer, atIndex: 0)
        self.roundRectLayer = shapeLayer
    }
}
