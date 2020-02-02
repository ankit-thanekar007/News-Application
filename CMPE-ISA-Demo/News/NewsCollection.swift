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
    var totalResults : Int
    enum CodingKeys: String, CodingKey {
        case articles, totalResults
    }
    
    init(articles: [NewsModel], results : Int) {
        self.articles = articles
        self.totalResults = results
    }
}
