//
//  NewsBoard.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class NewsBoard: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet private var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        fetchNews()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search News"
        searchController.extendedLayoutIncludesOpaqueBars = true;
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func fetchNews(){
        NewsDataController.shared.fetchNews { [weak self] (s, e) in
//            var indexPathSet : [IndexPath] = []
//            for i in (s..<e){
//                indexPathSet.append(IndexPath.init(row: 1, section: i))
//            }
//            self?.tableView.insertRows(at: indexPathSet, with: .automatic)
            self?.tableView.reloadData()
        }
    }
}

extension NewsBoard: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO:
    }
}

extension NewsBoard : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return NewsDataController.shared.collection.articles.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        cell.cellData = NewsDataController.shared.collection.articles[indexPath.section]
        cell.setData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == (NewsDataController.shared.collection.articles.count - 1) {
            self.fetchNews()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}

extension NewsBoard : UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let saveAction = UIContextualAction.init(style: .normal, title: "Save"){
            (action, view, bool) in
            print("Saved", indexPath)
        }
        saveAction.backgroundColor = UIColor.init(red: 157/255, green: 193/255, blue: 131/255, alpha: 1)
        return UISwipeActionsConfiguration.init(actions: [saveAction])
    }
}
