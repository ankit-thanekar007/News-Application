//
//  UserDetails.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 22/02/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit
import CoreData

class UserDetails: UIViewController {
    @IBOutlet private var tableView : UITableView!
    
    var articles : [News] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
