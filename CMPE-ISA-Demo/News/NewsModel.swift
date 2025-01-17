//
//  NewsModel.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class NewsModel: NSObject, Codable {
    let imageCache = NSCache<NSString, UIImage>()
    let source: Source?
    let author, title, welcomeDescription: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String!
    let content: String?
    var imageData : Data?
    var image : UIImage?
    
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
    
    
    required init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.decode(Source?.self, forKey: .source)
        title = try container.decode(String?.self, forKey: .title)
        welcomeDescription = try container.decode(String?.self, forKey: .welcomeDescription)
        url = try container.decode(String?.self, forKey: .url)
        urlToImage = try container.decode(String?.self, forKey: .urlToImage)
        content = try container.decode(String?.self, forKey: .content)
        author = try container.decode(String?.self, forKey: .author)
        let dateString = try container.decode(String.self, forKey: .publishedAt)
        publishedAt = dateString.formatFromString()
    }
    
}

extension NewsModel {
    
    func downloadImage(result : @escaping ((Bool, UIImage?)->Void))  {
        guard let urlToImage = urlToImage, let url = URL.init(string: urlToImage) else {
            let image = UIImage.init(named: "no-image")
            result(true, image);
            return
        }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            result(true, cachedImage)
            return
        }
        
        let session = URLSession.init(configuration: .default)
        let task = session.dataTask(with: url) {[weak self] (data, response, error) in
            if let d = data, let image = UIImage.init(data: d) {
                self?.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                result(true, image)
            }else {
                let image = UIImage.init(named: "no-image")
                result(false, image)
            }
        }
        task.resume()
    }
    
}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension Data {
    func image() -> UIImage? {
        return UIImage.init(data: self)
    }
}


extension UIImage {
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }
        case .scaleAspectFill:
            height = dimension
            width = ((size.width) / aspectRatio)/dimension
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
}

extension String {
    func formatFromString() -> String {
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "E, MMM d yyyy"
            dateFormatter.locale = tempLocale // reset the locale
            let dateString = dateFormatter.string(from: date)
            return dateString
        }
        return self
    }
}
