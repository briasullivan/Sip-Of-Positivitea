//
//  MassMessage.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 7/14/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//
import UIKit

internal class MassMessage {
    internal var messageContent: String?
    internal var messageImage: UIImage?
    init(messageContent: String) {
        self.messageImage = nil
        self.messageContent = messageContent
    }
    
    init(messageImage:UIImage) {
        self.messageImage = messageImage
        self.messageContent = nil
    }
    
    init(messageContent: String, messageImage:UIImage) {
        self.messageContent = messageContent
        self.messageImage = messageImage
    }
    
    init() {
        self.messageContent = nil;
        self.messageImage = nil;
    }
}
