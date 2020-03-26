//
//  User.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 08/03/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import FirebaseFirestore

class Message: MessageType {
    
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    var messageID : String!
    var message : String!
    var timestamp : String!
    var senderID : String!
    var senderName : String!
    var epochTime : Double!
    
    init(messageID : String,
         message : String,
         timestamp : String,
         senderID : String,
         senderName : String, epochTime : Double) {
        self.messageID = messageID
        self.message = message
        self.timestamp = timestamp
        self.senderID = senderID
        self.senderName = senderName
        self.messageId = messageID
        self.sender = Sender.init(id: senderID, displayName: senderName)
        self.kind = .text(message)
        self.sentDate = Date()
        self.epochTime = epochTime
    }
}
