//
//  PostersController.swift
//  Postr
//
//  Created by Steven Kingaby on 07/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit
import Alamofire

class PostersController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBAction func cancelToPostersController(segue:UIStoryboardSegue) {
    }

    @IBOutlet weak var postersTableView: UITableView!
    
    // Reference to http struct to networking
    // helper methods
    let httpNetworking = HTTPNetworking()
    
    // Reference to event and an array of
    // posters that belong to the event
    var event : Event!
    var posters = [Poster]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve posters that belong
        // to the event
        getPosters()
        
        // Set this view controller as delegate
        self.postersTableView.delegate = self;
        self.postersTableView.dataSource = self;
    }


    // Send http get request to retrieve posters for given event
    func getPosters() {
        httpNetworking.startActivityIndicator((self.postersTableView))
        let url = HTTPNetworking.postrURL + "/events/\(event.event_id)"
        let jwtToken = HTTPNetworking.JWT
        
        let headers = ["Authorization" : "Bearer \(jwtToken)"]
      
        Alamofire.request(.GET, url, headers: headers).responseJSON { response in
            
                if let JSON = response.result.value {
                    let postersDict = JSON as! NSDictionary
                    self.constructPostersArray(postersDict)
                    self.refreshPosterTableView()
                }
        }
        
        httpNetworking.stopActivityIndicator((self.postersTableView))
    }

    // Make poster array from json response from the server
    func constructPostersArray(eventsDict: NSDictionary) {
        var poster_id : Int
        var event_id : Int
        var title : String
        var authors : String
        var description : String
        var votes : Int

        // Clear array of previous entered events
        posters = []

        // Parse json objects and append json events to events array
        if let jsonPosters = eventsDict["posters"]! as? [[String : AnyObject]] {
            for poster in jsonPosters {
                poster_id = poster["poster_id"] as! Int
                event_id = poster["event_id"] as! Int
                title = poster["title"] as! String
                authors = poster["authors"] as! String
                description = poster["description"] as! String
                votes = poster["votes"] as! Int
                
                // Add to poster array
                posters.append(Poster(poster_id: poster_id, event_id: event_id, title: title,
                authors: authors, description: description, votes: votes))
            }
        }
        
        
        posters.sortInPlace { (poster1, poster2) -> Bool in
            return poster1.votes > poster2.votes
        }
    }
    
    
    // Reload data into poster array
    func refreshPosterTableView() {
         dispatch_async(dispatch_get_main_queue(), {
            self.postersTableView.reloadData()
            return
         })
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Set the nunmber of rows to be present in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posters.count
    }
    
    
    
    // Populate table view
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PosterCell", forIndexPath: indexPath)
        let poster = posters[indexPath.row] as Poster
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let voteLabel = cell.viewWithTag(2) as! UILabel
        let authorLabel = cell.viewWithTag(3) as! UILabel
        
        // Set title
        titleLabel.text = poster.title
        titleLabel.font! = UIFont(name: "coolvetica", size: 22)!
        
        // Set vote count
        voteLabel.text = "\(poster.votes)"
        voteLabel.font! =  UIFont(name: "coolvetica", size: 40)!
        
        // Set author
        authorLabel.text = poster.authors
        authorLabel.font! = UIFont(name: "coolvetica", size: 18)!
        
        return cell
    }

    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:
     NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}
