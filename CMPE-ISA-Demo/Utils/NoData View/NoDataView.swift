//
//  NoDataView.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 22/02/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class NoDataView: UIView {
    @IBOutlet private var image : UIImageView!
    @IBOutlet private var textLabel : UILabel!
    
    @IBInspectable var descriptionText : String = ""
    
    private var containerView : UIView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if(!descriptionText.isEmpty) {
            textLabel.text = descriptionText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "NoDataView", bundle: .main)
        containerView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        
        self.addSubview(self.containerView)
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
