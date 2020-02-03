//
//  NewsCell.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 31/01/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    
    @IBOutlet var newsTitle : UILabel!
    @IBOutlet var newsImage : UIImageView!
    @IBOutlet var newLoader : UIActivityIndicatorView!
    @IBOutlet var newsDate : UILabel!
    @IBOutlet var newsAuthor : UILabel!
    
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
