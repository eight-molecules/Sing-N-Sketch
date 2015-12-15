//
//  TestUIView.swift
//  Sing N Sketch
//
//  Created by Omer Al-Madani on 12/10/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation
//
//  ColorPickerView.swift
//  Sing N Sketch
//
//  Created by Omer Al-Madani on 12/2/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation
import UIKit

class ColorWheelView : UIImageView {
    
    var testColor: UIColor = UIColor(red: 0.5, green:0.0, blue:0.0, alpha: 1.0)
    var color: UIColor = UIColor(red: 0.5, green:0.0, blue:0.0, alpha: 1.0)
    
    
    override init(frame: CGRect) {
        
        
        super.init(frame: frame)
        
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //UIGraphicsBeginImageContext(frame.size)
        UIGraphicsBeginImageContext(CGSize(width: self.frame.width, height: self.frame.height))
        println("@@@@@@@@@@@@@@@@@@")
        println(frame.size)
        //UIImage(named: "drcolorpicker-colormap.png")!.drawInRect(self.bounds)
        UIImage(named: "drcolorpicker-colormap.png")!.drawInRect(CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width, self.frame.height))
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        bounds.origin = CGPointZero
        bounds.size = image!.size
        
        
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event!)
        if let touch = touches.first as? UITouch
        {
            let t = touch
            let point = t.locationInView(self)
            println(point)
            testColor = getPixelColorAtPoint(point)//colorAtPosition(point)
            println(testColor)
            
            //self.backgroundColor = testColor
            var view2: UIView = UIView(frame: CGRectMake(self.frame.origin.x, self.frame.origin.y, 10, 10))
            var gradient: CAGradientLayer = CAGradientLayer()
            gradient.startPoint = CGPointMake(0.0, 0.5)
            gradient.endPoint = CGPointMake(1.0, 0.5)
            gradient.frame = view2.bounds
            gradient.colors = [UIColor.whiteColor().CGColor, testColor.CGColor, UIColor.blackColor().CGColor]
            gradient.colors = [testColor.CGColor, UIColor.blackColor().CGColor]
            view2.layer.insertSublayer(gradient, atIndex: 0)
            self.addSubview(view2)
            
        }
    }
    
    //returns the color data of the pixel at the currently selected point
    func getPixelColorAtPoint(point:CGPoint)->UIColor
    {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, bitmapInfo)
        
        CGContextTranslateCTM(context, -point.x, -point.y)
        layer.renderInContext(context)
        var color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0, green: CGFloat(pixel[1])/255.0, blue: CGFloat(pixel[2])/255.0, alpha: CGFloat(pixel[3])/255.0)
        
        pixel.dealloc(4)
        return color
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchesEnded(touches!, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
    }
    
}