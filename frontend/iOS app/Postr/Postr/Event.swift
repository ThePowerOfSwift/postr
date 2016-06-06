//
//  Event.swift
//  Postr
//
//  Created by Steven Kingaby on 02/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

struct Event {
    var name: String?
    var description: String?
    var start_date: String?
    var end_date: String?
    
    init(name: String?, description: String?, start_date: String?, end_date: String?) {
        self.name = name
        self.description = description
        self.start_date = start_date
        self.end_date = end_date
    }
}
