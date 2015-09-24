//
//  LeftPanelViewController.swift
//  Sing N Sketch
//
//  Created by Emily Elizabeth Higgins on 9/16/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import UIKit

@objc
protocol LeftPanelViewControllerDelegate {

}

class LeftPanelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    struct TableView {
        struct CellIdentifiers {

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
    }
    
}


    

