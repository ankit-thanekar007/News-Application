//
//  LoadingFooter.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 08/02/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit

class LoadingFooter: UIView {
    @IBOutlet private var activityIndicator : UIActivityIndicatorView!
    @IBOutlet private var loadingText : UILabel!
    @IBInspectable var loaderBackground : UIColor = .white
    
    private var containerView : UIView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = loaderBackground
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
        
        let nib = UINib(nibName: "LoadingFooter", bundle: .main)
        containerView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView

        self.addSubview(self.containerView)
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    func startLoading(){
        activityIndicator.startAnimating()
    }
    
    func stopLoading(){
        activityIndicator.stopAnimating()
    }
    
    func setLoadingText(_ str : String){
        loadingText.text = str
    }
}



extension UIView {
    
    func fromNib<T : UIView>(view : T) -> T? {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? T
    }
    
}
