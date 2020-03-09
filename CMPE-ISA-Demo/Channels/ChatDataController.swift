//
//  ChatDataController.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 08/03/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol ObserveChannels {
    func channelsDidUpdate()
}

class ChatDataController: NSObject {
    static let shared = ChatDataController.init()
    
    var delegate : ObserveChannels?
    
    var masterChannelList : [Channel] = []
    
    func handleChannelUpdate(change : DocumentChange)  {
        switch change.type {
        case .added:
            let documentData = change.document.data()
            let channel = Channel.init(id: change.document.documentID,
                                       name: documentData["channelName"] as! String,
                                       owner: documentData["channelOwner"] as! String, created: documentData["channelCreated"] as! String )
            masterChannelList.append(channel)
            break
        case .modified:
            print(change.document.data())
            break
        case .removed:
            masterChannelList.removeAll { (channel) -> Bool in
                return channel.channelID == change.document.documentID
            }
            break
        }
    }
}
