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
                let timestamp = documentData["timestamp"] as?  String,
                let epoch = documentData["epoch"] as?  Double{
                let message = Message.init(messageID: change.document.documentID, message: message, timestamp: timestamp, senderID: senderID, senderName: senderName, epochTime: epoch)
                let messagePresent = masterMessageList.first { (m1) -> Bool in
                    return m1.messageID == change.document.documentID
                }
                if messagePresent == nil {
                    masterMessageList.append(message)
                    masterMessageList.sort { (m1, m2) -> Bool in
                        m1.epochTime < m2.epochTime
                    }
                }
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
