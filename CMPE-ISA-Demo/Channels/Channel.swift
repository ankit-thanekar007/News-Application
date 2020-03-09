//
//  Channel.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 08/03/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class Channel: NSObject {
    var channelID : String!
    var channelName : String!
    var channelOwner : String!
    var channelCreated : String!
    var messages : [Message] = []
    
    override init() {
        super.init()
    }
    
    init(id : String?, name : String, owner : String, created : String) {
        super.init()
        channelName = name
        channelID = id
        channelOwner = owner
        channelCreated = created
    }
}
