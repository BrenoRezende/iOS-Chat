//
//  Message.swift
//  Flash Chat
//
//  This is the model class that represents the blueprint for a message
//  Created by Breno Rezende on 10/09/19.
//  Copyright © 2019 brezende. All rights reserved.

struct Message {
    
    let sender: String
    let body: String
    
    init(sender: String, body: String) {
        self.sender = sender
        self.body = body
    }
    
}
