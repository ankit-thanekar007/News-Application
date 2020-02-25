//
//  ViewNewsOnWeb.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 21/02/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit
import WebKit;

class ViewNewsOnWeb: ParentController {
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    var myURLString : String = "https://www.google.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL.init(string: myURLString) {
            let request = URLRequest.init(url: url)
            webView.navigationDelegate = self
            webView.load(request)
        }else {
            let request = URLRequest.init(url:  URL.init(string: "https://www.google.com")!)
            webView.navigationDelegate = self
            webView.load(request)
        }
    }
}

extension ViewNewsOnWeb: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loader.startAnimating()
        webView.isHidden = true
  }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {        
        loader.stopAnimating()
        webView.isHidden = false
  }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.isHidden = false
    }
}
