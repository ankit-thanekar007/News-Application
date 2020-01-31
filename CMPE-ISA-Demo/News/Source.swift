//
//  Source.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class Source: NSObject, Codable {
    let id, name: String?

    enum CodingKeys: String, CodingKey {
        case id, name
    }
    
    init(id: String?, name: String?) {
        self.id = id
        self.name = name
    }
}
