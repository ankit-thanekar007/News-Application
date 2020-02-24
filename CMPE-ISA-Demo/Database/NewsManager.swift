//
//  NewsManager.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 15/02/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit
import CoreData

class NewsManager: NSObject {
    
    static func saveNews(_ newsModel : NewsModel)-> Bool{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        var result = false
        managedContext.performAndWait {
            if let newsEntity = NSEntityDescription.entity(forEntityName : "News", in: managedContext){
                let newsObject = NSManagedObject(entity: newsEntity, insertInto: managedContext)
                newsObject.setValue(newsModel.author, forKey: "author")
                newsObject.setValue(newsModel.content, forKey: "content")
                newsObject.setValue(newsModel.publishedAt, forKey: "publishedAt")
                newsObject.setValue(newsModel.title, forKey: "title")
                newsObject.setValue(newsModel.url, forKey: "url")
                newsObject.setValue(newsModel.urlToImage, forKey: "urlToImage")
                newsObject.setValue(Date(), forKey: "creationDate")
                do {
                    try managedContext.save()
                    appDelegate.saveContext()
                    result = true
                } catch let error {
                    print(error)
                }
            }
        }
        return result
    }
    
    static func fetchNews(_ newsModel : NewsModel)->News?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        fetchRequest.fetchLimit = 1
        let titlePredicate = NSPredicate(format: "title == %@", newsModel.title!)
        let authorPredicate = NSPredicate(format: "publishedAt == %@", newsModel.publishedAt)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [titlePredicate, authorPredicate])
        fetchRequest.predicate = andPredicate
            do {
                let fetchResult = try managedContext.fetch(fetchRequest)
                if let result = fetchResult.first as? News {
                    return result
                }
            } catch let error {
                print(error)
            }
        return nil
    }
    
    static func fetchAll()->[NewsModel]{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return []
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
            do {
                let fetchResult = try managedContext.fetch(fetchRequest)
                if let result = fetchResult as? [News] {
                    return mapToLocal(news: result)
                }
            } catch let error {
                print(error)
            }
        return []
    }
    
    static func mapToLocal(news : [News]) -> [NewsModel] {
        var localNews : [NewsModel] = []
        for newsObject in news {
            let newsmodel = NewsModel.init(source: Source.init(id: newsObject.newsSource?.id,
                                                               name: newsObject.newsSource?.name),
                                           author: newsObject.author,
                                           title: newsObject.title,
                                           welcomeDescription: newsObject.welcomeDescription,
                                           url: newsObject.url,
                                           urlToImage: newsObject.urlToImage,
                                           publishedAt: newsObject.publishedAt,
                                           content: newsObject.content)
            localNews.append(newsmodel)
        }
        return localNews
    }
    
    
    static func deleteNews(_ newsModel : NewsModel)-> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        if let toBeDeleted = fetchNews(newsModel) {
            managedContext.delete(toBeDeleted)
            do {
                try managedContext.save()
                appDelegate.saveContext()
                return true
            } catch let error {
                print(error)
                return false
            }
        }
        return false
    }
}
