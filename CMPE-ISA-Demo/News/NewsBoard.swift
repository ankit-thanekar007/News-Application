//
//  NewsBoard.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class NewsBoard: ParentController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var lastRefreshDate : Date!
    
    @IBOutlet private var tableView : UITableView!
    @IBOutlet private var loadingFooterHeight : NSLayoutConstraint!
    
    lazy var articles = {
        return NewsDataController.shared.collection.articles
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        configureRefreshControl()
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
    
    private func configureRefreshControl () {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString.init(string: "Last Refreshed At")
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(fetchNews),
                                            for: .valueChanged)
    }
    
    @objc private func fetchNews(){
        NewsDataController.shared.fetchNews { [weak self] (s, e) in
            var indexPathSet : [Int] = []
            for i in (s..<e){indexPathSet.append(i)}
            self?.tableView.insertSections(IndexSet.init(indexPathSet), with: .fade)
            self?.tableView.refreshControl?.endRefreshing()
            UIView.animate(withDuration: 0.5) { self?.loadingFooterHeight.constant = 0 }
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
        cell.cellData = articles()[indexPath.section]
        cell.setData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == (articles().count - 1) {
            UIView.animate(withDuration: 0.5) {
                self.loadingFooterHeight.constant = 50
            }
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
    
}
