//
//  NewsDataController.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

enum SortOptions : String {
    case relevancy = "relevancy"
    case popularity = "popularity"
    case publishedAt = "publishedAt"
}


class NewsDataController: NSObject {
    let wrapper = Wrapper.init()
    var pageNumber = 1
    
    var collection = NewsCollection.init(articles: [], results: -1)
    static let shared = NewsDataController.init()
    
    private func generateURL(searchText : String, sortBy : SortOptions) -> String {
        var base = "http://newsapi.org/v2/everything?apiKey=404fcb2608764b3983f73c8a4119b20d"
        base += "&page=\(pageNumber)"
        if(!searchText.isEmpty) {
            base += "&q=\(searchText)"
        }
        base += "&sortBy=\(sortBy.rawValue)"
        
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
    
    func fetchNews(searchText : String, sortBy : SortOptions, response : @escaping (((s : Int, e : Int))->Void)) {
        let nR = NewsRequest.init(
            response: {[weak self] (data, error) in
                if let e = error {
                    //TODO:
                    print("Failed to fetch news" + e.localizedDescription)
                }else {
                    if let d = data as? Data{
                        response(self!.mapToLocal(data: d))
                    }
                }
            },
            url: self.generateURL(searchText: searchText, sortBy: sortBy),
            headers: nil,
            data: nil)
        
        wrapper.GET(r: nR);
    }
    
    
    func mapToLocal(data : Data) -> (s : Int, e : Int)  {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(NewsCollection.self, from: data)
            if(collection.totalResults == -1) {
                collection = decoded
                return (s : 0, e : collection.articles.count)
            }else {
                collection.totalResults = decoded.totalResults
                let before = collection.articles.count
                separateArticlesAndAdd(data: data)
                return (s : before, e : collection.articles.count)
            }
        } catch let error {
            print("Failed to decode JSON " + error.localizedDescription)
        }
        return (s : 0, e : 0)
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

