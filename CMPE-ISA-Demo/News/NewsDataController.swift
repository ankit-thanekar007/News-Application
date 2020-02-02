//
//  NewsDataController.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class NewsDataController: NSObject {
    let wrapper = Wrapper.init()
    var pageNumber = 1
    
    var collection = NewsCollection.init(articles: [], results: -1)
    static let shared = NewsDataController.init()
    
    private func generateURL() -> String {
        var base = "https://newsapi.org/v2/top-headlines?country=us&apiKey=404fcb2608764b3983f73c8a4119b20d"
        base += "&page=\(pageNumber)"
        pageNumber+=1
        print("######### \(base) ########")
        return base
    }
    
    func shouldFetch() -> Bool{
        if collection.totalResults > collection.articles.count {
            return true
        }
        return false
    }
    
    func fetchNews( response : @escaping (()->Void)) {
        let nR = NewsRequest.init(
            response: {[weak self] (data, error) in
                if let e = error {
                    //TODO:
                    print("Failed to fetch news" + e.localizedDescription)
                }else {
                    if let d = data as? Data{
                        self?.mapToLocal(data: d)
                        response()
                    }
                }
            },
            url: self.generateURL(),
            headers: nil,
            data: nil)
        
        wrapper.GET(r: nR);
    }
    
    
    func mapToLocal(data : Data)  {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(NewsCollection.self, from: data)
            if(collection.totalResults == -1) {
                collection = decoded
            }else {
                collection.totalResults = decoded.totalResults
                separateArticlesAndAdd(data: data)
            }
        } catch let error {
            print("Failed to decode JSON " + error.localizedDescription)
        }
    }
    
    private func separateArticlesAndAdd(data : Data){
        let decoder = JSONDecoder()
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
            let articles = json?["articles"] as! [Any]
            let articleData = try JSONSerialization.data(withJSONObject: articles, options: .prettyPrinted)
            let decodedModels = try decoder.decode([NewsModel].self, from: articleData)
            collection.articles.append(contentsOf: decodedModels)
        }catch let error {
            print("Failed to decode JSON " + error.localizedDescription)
        }
    }
}
