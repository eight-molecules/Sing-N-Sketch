//
//  ContainerViewController.swift
//  Sing N Sketch
//
//  Created by Emily Elizabeth Higgins on 9/16/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case LeftPanelCollapsed
    case LeftPanelExpanded
}
class ContainerViewController: UIViewController {
    
    var centerNavigationController: UINavigationController!
    
    var viewController: ViewController!
    var currentState: SlideOutState = .LeftPanelCollapsed
    var leftViewController: LeftPanelViewController?
    
    let centerPanelExpandedOffset: CGFloat = 60
    

    override func viewDidLoad() {
        super.viewDidLoad()
        viewController = UIStoryboard.viewController()
        viewController.delegate = self
        
        //wrap the viewController in a navigation controller, so we can push views to it
        //and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: UIViewController())
        view.addSubview(navigationController!.view)
        
        navigationController!.didMoveToParentViewController(self)
    }
    
}

extension ContainerViewController: ViewControllerDelegate {
    func toggleLeftPanel(){
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            
            addChildLeftPanelController(leftViewController!)
        }
    }
    
    func addChildLeftPanelController(leftPanelController: LeftPanelViewController) {
        view.insertSubview(leftPanelController.view, atIndex: 0)
        
        addChildViewController(leftPanelController)
        leftPanelController.didMoveToParentViewController(self)
    }
    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateLeftPanel(#shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(navigationController!.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .LeftPanelCollapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
    }
    }
    
}

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func viewController() -> ViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? ViewController
    }
    
    class func leftViewController() -> LeftPanelViewController? {
            return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? LeftPanelViewController
    }
}


