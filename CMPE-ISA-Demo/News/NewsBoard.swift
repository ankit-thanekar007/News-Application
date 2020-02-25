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
    private let dataController = NewsDataController.shared
    
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isFiltering: Bool {
        let searchBarScopeIsFiltering =
            searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive || !isSearchBarEmpty
    }
    
    private var isSearching : Bool  {
        return searchController.isActive && (!isSearchBarEmpty)
    }
    
    private var isFetching : Bool = false
    
    private var filterType: SortOptions {
        switch searchController.searchBar.selectedScopeButtonIndex {
        case 0 :
            return .publishedAt
        case 1 :
            return .relevancy
        case 2 :
            return .popularity
        default:
            return .publishedAt
        }
    }
    
    @IBOutlet private var tableView : UITableView!
    @IBOutlet private var loadingFooterHeight : NSLayoutConstraint!
    @IBOutlet private var loaderView : LoadingFooter!
    @IBOutlet private var backgroundView : NoDataView!
    @IBOutlet private var loader : UIActivityIndicatorView!
    
    lazy var articles = {
        return NewsDataController.shared.collection.articles
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        configureRefreshControl()
        loaderView.stopLoading()
        showFullScreenLoader(true)
        fetchNews(shouldReset: true)
        tableView.register(UINib.init(nibName: "NewsCell", bundle: Bundle.main), forCellReuseIdentifier: "NewsCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func showFullScreenLoader(_ show : Bool){
        tableView.isHidden = show
        if(show) {
            loader.startAnimating()
        }else {
            loader.stopAnimating()
        }
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search News"
        searchController.extendedLayoutIncludesOpaqueBars = true;
        searchController.searchBar.showsSearchResultsButton = true
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["PublishedAt", "Relevancy", "Popularity"]
        searchController.searchBar.delegate = self
    }
    
    private func configureRefreshControl () {
        let refreshControl = UIRefreshControl()
        let lastUpdate = "Last updated at " + "\(Date().currentDateString())"
        refreshControl.attributedTitle = NSAttributedString.init(string: lastUpdate)
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(fetch),
                                            for: .valueChanged)
    }
    
    @objc func fetch(){
        showFullScreenLoader(true)
        self.fetchNews(shouldReset: true)
    }
    
    @objc func fetchNews(searchText : String = "SJSU", shouldReset : Bool){
        self.isFetching = true;
        
        if(shouldReset) {
            var prevIndexPathSet : [Int] = []
            for i in (0..<articles().count){prevIndexPathSet.append(i)}
            self.tableView.performBatchUpdates({
                self.dataController.removeArticles()
                self.tableView.deleteSections(IndexSet.init(prevIndexPathSet), with: .top)
            }, completion: { (completed) in
                
            })
        }
        
        NewsDataController.shared.fetchNews(searchText: searchText,
                                            sortBy: filterType,
                                            resetPage: shouldReset)
        { [weak self] (s, e) in
            
            var indexPathSet : [Int] = []
            for i in (s..<e){indexPathSet.append(i)}
            self?.tableView.performBatchUpdates({
                self?.showFullScreenLoader(false)
                self?.tableView.insertSections(IndexSet.init(indexPathSet), with: .fade)
                self?.tableView.refreshControl?.endRefreshing()
                self?.isFetching = false;
                self?.loaderView.stopLoading()
                UIView.animate(withDuration: 0.5) {
                    self?.loadingFooterHeight.constant = 0
                }
            }, completion: nil)
        }
    }
}

extension NewsBoard: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO:
    }
}

extension NewsBoard : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar,
                   selectedScopeButtonIndexDidChange selectedScope: Int) {
        if let searchText = searchBar.text {
            showFullScreenLoader(true)
            self.fetchNews(searchText: searchText.isEmpty ? "SJSU" : searchText,
                           shouldReset: true
            )
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            showFullScreenLoader(true)
            self.fetchNews(searchText: searchText.isEmpty ? "SJSU" : searchText, shouldReset: true)
        }
    }
}

extension NewsBoard : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundView = articles().count > 0 ? nil : backgroundView
        return articles().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        if articles().indices.contains(indexPath.section) {
            cell.cellData = articles()[indexPath.section]
            cell.setData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == (articles().count - 1) {
            UIView.animate(withDuration: 0.5) {
                self.loadingFooterHeight.constant = 50
                self.loaderView.startLoading()
            }
            self.searchController.searchBar.endEditing(true)
            self.view.endEditing(true)
            self.fetchNews(shouldReset: false)
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
