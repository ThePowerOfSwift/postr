//
//  EventInfoController.swift
//  Postr
//
//  Created by Steven Kingaby on 08/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit

class EventInfoController: UIViewController {
    var event : Event?
    
    @IBAction func cancelToEventInfoController(segue:UIStoryboardSegue) {
    }


    @IBOutlet weak var eventAddress: UITextView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventDate: UITextView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventsInfoView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()

        // Disable user interaction
        eventName.userInteractionEnabled = false
        eventDescription.userInteractionEnabled = false
        eventDate.userInteractionEnabled = false
        eventAddress.userInteractionEnabled = false
        
        // Set view text details to that of event
        eventName.text = event?.name
        eventAddress.text = event?.address
        eventDate.text = (event?.start_date)! + " - " + (event?.end_date)!
        eventDescription.text = event?.description
    }
    
    
    // Set styling attributes of view
    func setupStyle() {
        // Set table view shadow
        setShadow(eventsInfoView)
        
        eventName.font = UIFont(name: "coolvetica", size: 27)!
        eventAddress.font = UIFont(name: "coolvetica", size: 20)!
        eventDate.font = UIFont(name: "coolvetica", size: 20)!
        eventDescription.font = UIFont(name: "coolvetica", size: 20)!
        eventDate.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0)
        eventDescription.contentInset = UIEdgeInsetsMake(-15,0,0,0);
    
        // Set shadow for event name
        setShadow(eventName)

    }

    // Cast shadow around given uiview
    func setShadow(view: UIView) {
        view.clipsToBounds = false;
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 5
    }
   
    // Pass on relevant data to next view in navigation sequence
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "segueVote") {
            let navController = segue!.destinationViewController as! UINavigationController
            let voteController = navController.topViewController as! VoteController;
            voteController.event = event
        }
    }
}
