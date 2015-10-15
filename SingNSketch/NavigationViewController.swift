//
//  NavigationViewController.swift
//  Sing N Sketch
//
//  Created by Dakota-Cheyenne Bernard Brown on 10/14/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation

class NavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Status bar white font
        self.navigationBar.barStyle = UIBarStyle.Black
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.barTintColor = UIColor(red: CGFloat(61/255.0), green: CGFloat(60/255.0), blue: CGFloat(62/255.0), alpha: 1.0)
    }
}