//
//  httpNetworking.swift
//  Postr
//
//  Created by Steven Kingaby on 08/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

//import Alamofire
import Foundation
import UIKit

struct HTTPNetworking {
    // Networking variables
    static let postrURL = "https://0df2246d.ngrok.io"
    static var JWT : String!
    static var username : String!
    
    func startActivityIndicator(view: UIView) {
    
        let holderView: UIView = UIView()
        holderView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        holderView.frame = view.frame
        holderView.center = view.center
        
        let activityIndicatorView: UIView = UIView()
        activityIndicatorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.75)
        activityIndicatorView.frame = CGRectMake(0, 0, 90, 90)
        activityIndicatorView.center = view.center
        activityIndicatorView.clipsToBounds = true
        activityIndicatorView.layer.cornerRadius = 10

        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.center = CGPointMake(activityIndicatorView.frame.size.width / 2,
                                               activityIndicatorView.frame.size.height / 2);
        
        // Add views to parent views
        activityIndicatorView.addSubview(activityIndicator)
        holderView.addSubview(activityIndicatorView)
        
        // Set ids for later reference
        activityIndicator.tag = 3
        activityIndicatorView.tag = 2
        holderView.tag = 1
        
        // Add to superviews in order to become
        // visible onscreen
        view.addSubview(holderView)
        activityIndicator.startAnimating()
    }
    
    
    func stopActivityIndicator(view: UIView) {
        // Obtain reference to activity indicator
        let holderView = view.viewWithTag(1)
        let activityIndicatorView = holderView!.viewWithTag(2)
        let activityIndicator = activityIndicatorView!.viewWithTag(3) as? UIActivityIndicatorView
    
        // Stop animationg and restore original background
        activityIndicator!.stopAnimating()
        holderView!.removeFromSuperview()
    }

}
