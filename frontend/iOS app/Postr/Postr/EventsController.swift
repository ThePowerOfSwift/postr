//
//  EventsViewController.swift
//  Postr
//
//  Created by Steven Kingaby on 02/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import MapKit


// UITableViewController
class EventsController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate  {
    @IBOutlet weak var eventsTableView: UITableView!

    @IBAction func cancelToEventsController(segue:UIStoryboardSegue) {
    }
    
    // Variables to handle location data
    var locationManager = CLLocationManager()
    var userLocation : CLLocation?
    
    // Variables to http networking and responses
    var events = [Event]()
    var eventsEmpty = true
    let httpNetworking = HTTPNetworking()
    
    

    override func viewDidLoad() {
        // setup Location manager so we can access user's location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Call super class
        super.viewDidLoad()
        
        // Set view design attributes
        setUpStyle()
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // set user's location
        userLocation = locations[0]
        
        if (eventsEmpty) {
            eventsEmpty = false
            getEvents()
        }
    }
    
    
    func setUpStyle() {
        // Set table view shadow
        eventsTableView.clipsToBounds = false;
        eventsTableView.layer.shadowColor = UIColor.blackColor().CGColor
        eventsTableView.layer.shadowOffset = CGSize(width: 0, height: 0)
        eventsTableView.layer.shadowOpacity = 0.4
        eventsTableView.layer.shadowRadius = 5
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Trigger repopulation of events array with 
        // potentially new events
        eventsEmpty = true
    }
    
    // Send http request to server to retrieve events in response
    func getEvents() {
        httpNetworking.startActivityIndicator((self.eventsTableView))
        let latitude = userLocation!.coordinate.latitude
        let longitude = userLocation!.coordinate.longitude
        
        let url = HTTPNetworking.postrURL + "/nearestEvents"
        let jwtToken = HTTPNetworking.JWT
        
        let headers = ["Authorization" : "Bearer \(jwtToken)"]
        let parameters = ["latitude" : latitude, "longitude": longitude]
      
        Alamofire.request(.POST, url, headers: headers, parameters: parameters).responseJSON { response in
                if let JSON = response.result.value {
                    let eventsDict = JSON as! NSDictionary
                    self.constructEventsArray(eventsDict)
                    self.refreshEventTableView()
                }
        }
        
        httpNetworking.stopActivityIndicator((self.eventsTableView))
    }
    
    func constructEventsArray(eventsDict: NSDictionary) {
        var event_id : Int
        var name : String
        var address : String
        var start_date : String
        var end_date : String
        var description : String
        let noOfEvents = 5
        var eventCounter = 0

        // Clear array of previous entered events
        events = []

        // Parse json objects and append json events to events array
        if let jsonEvents = eventsDict["events"]! as? [[String : AnyObject]] {
            for event in jsonEvents {
                event_id = event["event_id"] as! Int
                name = event["name"] as! String
                address = event["address"] as! String
                start_date = event["start_date"] as! String
                end_date = event["end_date"] as! String
                description = event["description"] as! String
                
                if (eventCounter < noOfEvents) {
                    events.append(Event(event_id: event_id, name: name, address: address, start_date: start_date,
                    end_date: end_date, description: description))
                } else {
                    break
                }
                
                eventCounter += 1
            }
        }
    }
    
    // Reload data into events array
    func refreshEventTableView() {
         dispatch_async(dispatch_get_main_queue(), {
            self.eventsTableView.reloadData()
            return
         })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // Set the number of rows present in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    

    // Populate table views
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath)
        let event = events[indexPath.row] as Event
        
        cell.imageView!.image = UIImage(named: "event\(indexPath.row)")
        cell.imageView!.layer.masksToBounds = true
        cell.imageView!.layer.cornerRadius = 5
        
        cell.textLabel?.text = event.name
        cell.textLabel?.font! = UIFont(name: "coolvetica", size: 22)!
        cell.detailTextLabel?.text = event.start_date
        cell.detailTextLabel?.font! = UIFont(name: "coolvetica", size: 16)!
        
        return cell
    }

    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "segueEvent") {
            let index = eventsTableView.indexPathForSelectedRow?.row
            let selectedEvent = events[index!] as Event
            let navController = segue!.destinationViewController as! UINavigationController
            let eventInfoController = navController.topViewController as! EventInfoController;
            eventInfoController.event = selectedEvent
        }
    }
}
