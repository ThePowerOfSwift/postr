//
//  Poster.swift
//  Postr
//
//  Created by Steven Kingaby on 20/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

struct Poster {
    var poster_id: Int
    var event_id: Int
    var title: String?
    var authors: String?
    var description: String?
    var votes: Int
    
    init(poster_id: Int, event_id: Int, title: String?, authors: String?, description: String?, votes: Int) {
        self.poster_id = poster_id
        self.event_id = event_id
        self.title = title
        self.authors = authors
        self.description = description
        self.votes = votes
    }
}

