//
//  UserDetails.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 22/02/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit
import CoreData

class UserDetails: UIViewController {
    
    @IBOutlet private var tableView : UITableView!
    @IBOutlet private var backgroundView : NoDataView!
    
    private let persistentContainer = NSPersistentContainer(name: "CMPE_ISA_Demo")
    private var selectedURL : String!
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<News> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<News> = News.fetchRequest()

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                    managedObjectContext: managedContext,
                                    sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller

        return fetchedResultsController
    }()
    
    
    lazy var articles = {
        return NewsManager.fetchAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "NewsCell", bundle: Bundle.main), forCellReuseIdentifier: "NewsCell")
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
            } else {
                self.loadOfflineData()
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController.delegate = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResultsController.delegate = self
        loadOfflineData()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowOfflineNews") {
            let vc = segue.destination as! ViewNewsOnWeb
            vc.myURLString = selectedURL ?? ""
        }
    }
    
    
    private func loadOfflineData(){
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
}

extension UserDetails : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let news = fetchedResultsController.fetchedObjects else {return 0}
        tableView.backgroundView = news.count > 0 ? nil : backgroundView
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        cell.cellData = mapToLocal(newsObject: (fetchedResultsController.fetchedObjects?[indexPath.section])!)
        cell.setData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    
    func mapToLocal(newsObject : News) -> NewsModel {
        let newsmodel = NewsModel.init(source: Source.init(id: newsObject.newsSource?.id,
                                                           name: newsObject.newsSource?.name),
                                       author: newsObject.author,
                                       title: newsObject.title,
                                       welcomeDescription: newsObject.welcomeDescription,
                                       url: newsObject.url,
                                       urlToImage: newsObject.urlToImage,
                                       publishedAt: newsObject.publishedAt,
                                       content: newsObject.content)
        
        return newsmodel
    }
}

extension UserDetails : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedURL = fetchedResultsController.fetchedObjects?[indexPath.section].url
        performSegue(withIdentifier: "ShowOfflineNews", sender: self)
    }
}

extension UserDetails: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
        tableView.reloadData()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            tableView.reloadData()
            break
        case .delete:
            tableView.reloadData()
            break;
        case .move:
            print("In Move")
            break;
        default:
            print("... Default")
        }
    }
}

