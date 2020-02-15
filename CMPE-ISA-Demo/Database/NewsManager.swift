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
        
        if let newsEntity = NSEntityDescription.entity(forEntityName : "News", in: managedContext){
            let newsObject = NSManagedObject(entity: newsEntity, insertInto: managedContext)
            newsObject.setValue(newsModel.author, forKey: "author")
            newsObject.setValue(newsModel.content, forKey: "content")
            newsObject.setValue(newsModel.publishedAt, forKey: "publishedAt")
            newsObject.setValue(newsModel.title, forKey: "title")
            newsObject.setValue(newsModel.url, forKey: "url")
            newsObject.setValue(newsModel.urlToImage, forKey: "urlToImage")
            do {
                try managedContext.save()
                return true
            } catch let error {
                print(error)
                return false
            }
        }
        return false
    }
    
    
    static func fetchNews(_ newsModel : NewsModel)->News?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
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
    
    static func fetchAll()->[News]{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return []
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
            do {
                let fetchResult = try managedContext.fetch(fetchRequest)
                if let result = fetchResult as? [News] {
                    return result
                }
            } catch let error {
                print(error)
            }
        return []
    }
    
    static func deleteNews(_ newsModel : NewsModel)-> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if let toBeDeleted = fetchNews(newsModel) {
            managedContext.delete(toBeDeleted)
            do {
                try managedContext.save()
                return true
            } catch let error {
                print(error)
                return false
            }
        }
        return false
    }
}
