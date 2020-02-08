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
    @IBOutlet private var newsAuthor : UILabel!
    
    var cellData : NewsModel!
    let session = URLSession(configuration: .default)
    
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
        newsTitle.text = ""
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
            newLoader.startAnimating()
            self.cellData.downloadImage { (result) in
                DispatchQueue.main.async {
                    if result {
                        if let id = self.cellData.image {
                            self.newsImage?.image = id
                        }
                    }
                    self.newLoader.stopAnimating()
                }
            }
        }
    }
}
