//
//  Conversation.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 4/23/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//
import UIKit

internal class Conversation {
    internal let id: String
    internal let first_name: String
    internal let last_name: String
    internal let phone_number: String
    internal let last_received_message: Date
    
    init(id: String, first_name: String, last_name: String, phone_number: String, last_received_message: Date) {
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.phone_number = phone_number
        self.last_received_message = last_received_message
    }
}
