//
//  CropView.swift
//  Postr
//
//  Created by Steven Kingaby on 18/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit

class CropView: UIView {
    let border = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Create dashed border
        createBorder()
        
        // Set slightly transparent background
        self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        self.alpha = 0.5
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create border and set its outline along this crop view
        border.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 0).CGPath
        border.frame = self.bounds
    }
    
    // Draws border around crop view
    func createBorder() {
        // Set border properties
        border.lineDashPattern = [4, 4]
        border.lineWidth = 3
        border.strokeColor = UIColor(red:1.00, green:0.60, blue:0.00, alpha:1.0).CGColor
        border.fillColor = nil

        // Add border to view
        self.layer.addSublayer(border)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
