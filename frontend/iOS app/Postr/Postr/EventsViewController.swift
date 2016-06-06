//
//  EventsViewController.swift
//  Postr
//
//  Created by Steven Kingaby on 02/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit


// UITableViewController
class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var events:[Event] = eventData
    
    @IBOutlet weak var eventsTableView: UITableView!
    

    @IBAction func canceltoEventsViewController(segue:UIStoryboardSegue) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table view shadow
        eventsTableView.clipsToBounds = false;
        eventsTableView.layer.shadowColor = UIColor.blackColor().CGColor
        eventsTableView.layer.shadowOffset = CGSize(width: 0, height: 0)
        eventsTableView.layer.shadowOpacity = 0.4
        eventsTableView.layer.shadowRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Changes status bar style for this specific view controller and then
    // changes it back for when the next view controller is loaded
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
//    }


    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }
    


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath)
        let event = events[indexPath.row] as Event
        
        cell.imageView!.image = UIImage(named: "pet\(indexPath.row)")
        cell.imageView!.layer.masksToBounds = true
        cell.imageView!.layer.cornerRadius = 5
        
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.start_date
        
        return cell
    }
    

//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
// 
//    }



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

//    // Override to support rearranging the table view.
//    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
//
//    }

//    // Override to support conditional rearranging of the table view.
//    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
