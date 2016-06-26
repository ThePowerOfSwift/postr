//
//  Event.swift
//  Postr
//
//  Created by Steven Kingaby on 02/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

// Represents a Postr event in which users vote for their favourite posters
struct Event {
    var event_id: Int
    var name: String?
    var address: String?
    var start_date: String?
    var end_date: String?
    var description: String?
    
    init(event_id: Int, name: String?, address: String?, start_date: String?, end_date: String?, description: String?) {
        self.event_id = event_id
        self.name = name
        self.address = address
        self.start_date = start_date
        self.end_date = end_date
        self.description = description
    }
}
