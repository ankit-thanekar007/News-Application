//
//  ParentController.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 08/02/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit
import CoreLocation
class ParentController: UIViewController {
    private let manager = LocationManager.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
    }
    
    func alertUser(title : String, message : String)  {
        let settingsApp = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(title: title ,
                                      message: message ,
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Location Access",
                                      style: .cancel,
                                      handler: { (alert) -> Void in
                                        UIApplication.shared.open(settingsApp,
                                                                  options: [:],
                                                                  completionHandler: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension ParentController : LocationDelegate {
    
    func locationUpdatedTo(loc: CLLocation) {
        print(loc)
    }
    
    func deniedLocation() {
        alertUser(title: "Need Location Access", message: "Location access is required for updating news according to your location")
    }
    
    func restrictedLocation() {
        alertUser(title: "Need Location Access", message: "Location access is required for updating news according to your location")
    }
}
