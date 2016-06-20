//
//  ZoomView.swift
//  Postr
//
//  Created by Steven Kingaby on 18/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit

class ZoomView: UIView {
    var button: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, zoomIn: Bool) {
        super.init(frame: frame)
        
        let buttonFrame : CGRect = CGRect(origin: CGPointZero, size: self.frame.size)
        button = UIButton(frame: buttonFrame)
        button.titleLabel!.font = UIFont(name: "coolvetica", size: 50)
        button.titleLabel!.textColor = UIColor.whiteColor()
     
        // Set icons and their relative libraries
        if (zoomIn) {
            button.setTitle("+", forState: UIControlState.Normal)
            button.titleLabel!.font = UIFont(name: "coolvetica", size: 45)
        } else {
            button.setTitle("-", forState: UIControlState.Normal)
            button.titleLabel!.font = UIFont(name: "coolvetica", size: 58)
        }
        
        self.addSubview(button)
    }
    
    // By Apple library standards, this overriding method has
    // to be written, even if it isn't called.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
