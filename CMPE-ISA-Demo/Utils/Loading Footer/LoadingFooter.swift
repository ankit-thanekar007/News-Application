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
    @IBInspectable var loaderBackground : UIColor = .white
    
    var containerView : UIView!
    
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
    
    func commonInit() {
        guard let view = fromNib(view: self) else {return}
        view.frame = self.bounds
        self.addSubview(view)
    }
}



extension UIView {
    
    func fromNib<T : UIView>(view : T) -> T? {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? T
    }
    
}
