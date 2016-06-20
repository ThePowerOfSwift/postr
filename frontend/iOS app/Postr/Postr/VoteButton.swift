//
//  VoteButton.swift
//  Postr
//
//  Created by Steven Kingaby on 08/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit

class VoteButton: UIButton {
    var roundRectLayer: CAShapeLayer?
    
    // Corner radius of the background rectangle
    var roundRectCornerRadius: CGFloat = 10
    
    // Color of the background rectangle
    var rectangleColor: UIColor = UIColor(red:1.00, green:0.60, blue:0.00, alpha:1.0)

    override func layoutSubviews() {
        super.layoutSubviews()
        configurePostrButton()
    }
    
    func configurePostrButton() {
        // Change button font family and font color
        self.titleLabel!.font = UIFont(name: "coolvetica", size: 45)
        self.titleLabel!.textColor = UIColor.whiteColor()
        
        // Set button shadow
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 5
        
        // Remove from parent layer
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        
        // Draw and present the shape
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).CGPath
        shapeLayer.fillColor = rectangleColor.CGColor
        self.layer.insertSublayer(shapeLayer, atIndex: 0)
        self.roundRectLayer = shapeLayer
    }
}
