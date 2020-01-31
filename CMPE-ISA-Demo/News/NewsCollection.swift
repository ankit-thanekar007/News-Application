//
//  NewsCollection.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class NewsCollection: NSObject, Codable {
    var articles: [NewsModel] = []
    
    enum CodingKeys: String, CodingKey {
        case articles
    }
    
    init(articles: [NewsModel]) {
        self.articles = articles
    }
}
