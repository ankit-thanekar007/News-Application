//
//  Wrapper.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

protocol WRequest {
    var url : String { get set}
    var headers : [String : Any]? {get set}
    var data : Data? {get set}
    var response : ((Any, WError?)->Void) {get set}
}

struct WError {
    var status : Int
    var message : String
}


struct NewsRequest : WRequest {
    var response: ((Any, WError?) -> Void)
    var url: String
    var headers: [String : Any]?
    var data: Data?
}


class Wrapper: NSObject {
    let session = URLSession(configuration: .default)
    var task: URLSessionDataTask?
    
    func GET(r : WRequest){
        task?.cancel()
        if let urlComponents = URLComponents(string: r.url){
          guard let url = urlComponents.url else {
            return
          }
          task = session.dataTask(with: url) { [weak self] data, response, error in
            defer {
              self?.task = nil
            }
            if let error = error {
                r.response([], WError.init(status: 400, message: "Bad Request"))
              print ("DataTask error: " + error.localizedDescription + "\n")
            } else if let data = data, let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                r.response(data, nil)
            }else if let response = response as? HTTPURLResponse, response.statusCode == 426 {
                r.response([],  WError.init(status: response.statusCode, message: response.description))
            }
          }
          task?.resume()
        }
    }
}
