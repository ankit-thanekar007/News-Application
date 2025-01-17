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

let BASE_URL : String = "http://newsapi.org/v2"
let API_KEY : String = "404fcb2608764b3983f73c8a4119b20d"

class NewsDataController: NSObject {
    let wrapper = Wrapper.init()
    var pageNumber = 1
    
    var collection = NewsCollection.init(articles: [], results: -1)
    static let shared = NewsDataController.init()
    
    private func generateURL(searchText : String,
                             sortBy : SortOptions,
                             resetPage : Bool) -> String {
        if(resetPage){
            pageNumber = 1
        }
        let base = "\(BASE_URL)/everything?apiKey=\(API_KEY)&page=\(pageNumber)&q=\(searchText)&sortBy=\(sortBy.rawValue)&pageSize=20&language=en"
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
    
    func fetchNews(searchText : String, sortBy : SortOptions,
                   resetPage : Bool = false,
                   response : @escaping ((_ success : Bool,(s : Int, e : Int))->Void)) {
        let nR = NewsRequest.init(
            response: {[weak self] (data, error) in
                if let e = error {
                    response(false,(0,0))
                    self!.pageNumber = self!.pageNumber - 1;
                    print("Failed to fetch news", e)
                }else {
                    if let d = data as? Data{
                        response(true,self!.mapToLocal(data: d, reset: resetPage))
                    }
                }
            },
            url: self.generateURL(searchText: searchText, sortBy: sortBy, resetPage: resetPage),
            headers: nil,
            data: nil)
        wrapper.GET(r: nR);
    }
    
    func removeArticles() {
        collection.articles.removeAll()
    }
    
    func mapToLocal(data : Data, reset : Bool) -> (s : Int, e : Int)  {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(NewsCollection.self, from: data)
            if(collection.totalResults == -1 || reset) {
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

extension Date {
    func currentDateString() -> String {
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "E, MMM d HH:mm:ss"
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
