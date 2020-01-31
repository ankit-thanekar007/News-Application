//
//  NewsModel.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class NewsModel: NSObject, Codable {
    let source: Source?
    let author, title, welcomeDescription: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case welcomeDescription = "description"
        case url, urlToImage, publishedAt, content
    }
    
    init(source: Source?, author: String?, title: String?, welcomeDescription: String?, url: String?, urlToImage: String?, publishedAt: String?, content: String?) {
        self.source = source
        self.author = author
        self.title = title
        self.welcomeDescription = welcomeDescription
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.content = content
    }
    
}
