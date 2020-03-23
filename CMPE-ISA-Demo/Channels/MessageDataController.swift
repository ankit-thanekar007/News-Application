//
//  MessageDataController.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 16/03/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol ObserveMessages {
    func messagesDidUpdate()
}

class MessageDataController: NSObject {
    static let shared = MessageDataController.init()
    
    var delegate : ObserveMessages?
    
    var masterMessageList : [Message] = []
    
    func handleMessageUpdate(change : DocumentChange)  {
        switch change.type {
        case .added:
            let documentData = change.document.data()
            if let message = documentData["message"] as?  String,
                let senderID = documentData["senderID"] as?  String,
                let senderName = documentData["senderName"] as?  String,
                let timestamp = documentData["timestamp"] as?  String {
                let message = Message.init(messageID: change.document.documentID, message: message, timestamp: timestamp, senderID: senderID, senderName: senderName)
                masterMessageList.append(message)
            }
            break
        case .modified:
            print(change.document.data())
            break
        case .removed:
            masterMessageList.removeAll { (message) -> Bool in
                return message.messageID == change.document.documentID
            }
            break
        }
        delegate?.messagesDidUpdate()
    }
    
    
}
