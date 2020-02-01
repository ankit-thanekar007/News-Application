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
    let urlToImage: String
    let publishedAt: String?
    let content: String?
    var imageData : Data?
    
    enum CodingKeys: String, CodingKey {
        case source, author, title
        case welcomeDescription = "description"
        case url, urlToImage, publishedAt, content, imageData
    }
    
    init(source: Source?, author: String?, title: String?, welcomeDescription: String?, url: String?, urlToImage: String, publishedAt: String?, content: String?, imageData : Data?) {
        self.source = source
        self.author = author
        self.title = title
        self.welcomeDescription = welcomeDescription
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.content = content
        self.imageData = imageData
    }
}

extension NewsModel {
    
    func downloadImage(result : @escaping ((Bool)->Void))  {
        if(imageData != nil){result(true); return}
        let session = URLSession.init(configuration: .default)
        let task = session.dataTask(with: URL.init(string: urlToImage)!) {[weak self] (data, response, error) in
            if data != nil {
                self?.imageData = data
                result(true)
            }else {
                self?.imageData = nil
                result(false)
            }
        }
        task.resume()
    }
    
}