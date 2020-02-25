//
//  NewsCell.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    
    @IBOutlet private var newsTitle : UILabel!
    @IBOutlet private var newsDescription : UILabel!
    @IBOutlet private var newsImage : UIImageView!
    @IBOutlet private var newLoader : UIActivityIndicatorView!
    @IBOutlet private var newsDate : UILabel!
    @IBOutlet private var offlineStatus : UIImageView!
    
    var cellData : NewsModel!
    let session = URLSession(configuration: .default)
    var isSaved : Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        newLoader.stopAnimating()
    }
    
    override func prepareForReuse() {
        newsImage.image = nil
        offlineStatus.image = nil
        newsTitle.text = ""
        isSaved = false
    }
    
    func setData(){
        if let d = cellData {
            newsTitle.text = d.title
            newsDescription.text = d.content
            if let publishd = d.publishedAt, let author = d.author {
                newsDate.text = "\(publishd) By \(author)"
            }else {
                newsDate.text = d.publishedAt
            }
            downloadMedia()
            if((NewsManager.fetchNews(d)) != nil) {
                offlineStatus.image = UIImage.init(named: "saved")
                isSaved = true
            }else {
                offlineStatus.image = UIImage.init(named: "unsaved")
                isSaved = false
            }
        }
    }
    
    func downloadMedia(){
        newLoader.startAnimating()
        self.cellData.downloadImage { (result, image) in
            DispatchQueue.main.async {
                if let image = image {
                    self.newsImage?.image = image
                }
                self.newLoader.stopAnimating()
            }
        }
    }
    
    @IBAction func changeOfflineStatus(_ view : UIControl){
        if(isSaved) {
            if NewsManager.deleteNews(self.cellData) {
                offlineStatus.image = UIImage.init(named: "unsaved")
                isSaved = false
            }
        }else {
            if NewsManager.saveNews(self.cellData) {
                offlineStatus.image = UIImage.init(named: "saved")
                isSaved = true
            }
        }
    }
}
