//
//  ButtonView.swift
//  Postr
//
//  Created by Steven Kingaby on 18/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit

class ButtonView: UIView {
    var button: VoteButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let buttonFrame : CGRect = CGRect(origin: CGPointZero, size: self.frame.size)
        
        // Set button size and position
        button = VoteButton(frame: buttonFrame)
        button.setTitle("Vote", forState: UIControlState.Normal)
        
        // Add button to view
        self.addSubview(button)
    }
    
    // By Apple library standards, this overriding method has
    // to be written, even if it isn't called.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
