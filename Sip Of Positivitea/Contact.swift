//
//  Conversation.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 4/23/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

internal class Contact {
    internal let id: String
    internal let first_name: String
    internal let last_name: String
    internal let phone_number: String
    internal let email: String
    internal let notification_id: String
    
    init(id: String, first_name: String, last_name: String, phone_number: String, email: String) {
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.phone_number = phone_number
        self.email = email
        self.notification_id = ""
    }
    
    init(id: String, first_name: String, last_name: String, phone_number: String, email: String, notification_id: String) {
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.phone_number = phone_number
        self.email = email
        self.notification_id = notification_id
    }
}
