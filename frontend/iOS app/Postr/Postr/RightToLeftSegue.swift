//
//  RightToLeftSegue.swift
//  Postr
//
//  Created by Steven Kingaby on 02/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit

class RightToLeftSegue: UIStoryboardSegue {

    // REWRITE THIS CODE!!!!
    // taken from stackoverflow
    override func perform() {
        let src = self.sourceViewController as UIViewController
        let dst = self.destinationViewController as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransformMakeTranslation(src.view.frame.size.width, 0)

        UIView.animateWithDuration(0.25,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
            },
            completion: { finished in
                src.presentViewController(dst, animated: false, completion: nil)
            }
        )
    }
}


class RightToLeftUnwindSegue: UIStoryboardSegue {
    
    // REWRITE THIS CODE!!!!
    // taken from stackoverflow
    override func perform()
    {
        let src = self.sourceViewController as UIViewController
        let dst = self.destinationViewController as UIViewController
        
        src.view.superview?.insertSubview(dst.view, belowSubview: src.view)
        src.view.transform = CGAffineTransformMakeTranslation(0, 0)
        
        UIView.animateWithDuration(0.25,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                src.view.transform = CGAffineTransformMakeTranslation(src.view.frame.size.width, 0)
            },
            completion: { finished in
                src.dismissViewControllerAnimated(false, completion: nil)
            }
        )
    }
}
