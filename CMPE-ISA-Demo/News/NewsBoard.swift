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
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func fetchNews(){
        NewsDataController.shared.fetchNews { [weak self] in
            self?.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
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
        return NewsDataController.shared.collection.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        cell.cellData = NewsDataController.shared.collection.articles[indexPath.row]
        cell.setData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (NewsDataController.shared.collection.articles.count - 1) {
            self.fetchNews()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if NewsDataController.shared.shouldFetch() {
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 100))
            view.backgroundColor = .red
            let activityIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
            activityIndicator.center = view.center
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return NewsDataController.shared.shouldFetch() ? 100 : 0.0001
    }
}

extension NewsBoard : UITableViewDelegate {
    
}
