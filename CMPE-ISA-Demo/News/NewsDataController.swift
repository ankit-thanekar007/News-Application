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
    var collection = NewsCollection.init(articles: [])
    static let shared = NewsDataController.init()
    
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
            url: "https://newsapi.org/v2/everything?q=bitcoin&apiKey=404fcb2608764b3983f73c8a4119b20d",
            headers: nil,
            data: nil)
        
        wrapper.GET(r: nR);
    }
    
    
    func mapToLocal(data : Data)  {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(NewsCollection.self, from: data)
            collection = decoded
        } catch let error {
            print("Failed to decode JSON" + error.localizedDescription)
        }
    }
    
    
    
    
    
}
