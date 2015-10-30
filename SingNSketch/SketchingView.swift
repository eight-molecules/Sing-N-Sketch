//
//  SketchingView.swift
//  Sing N Sketch
//
//  Created by Dakota-Cheyenne Brown on 9/27/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation
import UIKit

class SketchingView: UIView {
    
    
    //stores previously drawn path
    var drawImage: UIImage!
    var brush: Brush = Brush()
    var palette: Palette = Palette()
    var audio: AudioInterface = AudioInterface()

    @IBOutlet weak var hide: UIButton!
    @IBOutlet weak var show: UIButton!
    @IBOutlet weak var newDrawing: UIButton!
    
    @IBOutlet weak var drawView: UIImageView!
    @IBOutlet weak var canvasView: UIImageView!
    
    //variables for points of the quadratic curve
    var lastPoint = CGPoint.zeroPoint
    var prevPoint1 = CGPoint.zeroPoint
    var prevPoint2 = CGPoint.zeroPoint
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .whiteColor()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        palette = Palette()
        palette.addColor(440, color: UIColor.redColor())
        palette.addColor(660, color: UIColor.orangeColor())
        palette.addColor(880, color: UIColor.greenColor())
        palette.addColor(1320, color: UIColor.blueColor())
        palette.addColor(1760, color: UIColor.purpleColor())
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            prevPoint1 = touch.previousLocationInView(self)
            
            prevPoint2 = touch.previousLocationInView(self)
            
            lastPoint = touch.previousLocationInView(self)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch{
        
            let currentPoint = touch.locationInView(self)
            
            prevPoint2 = prevPoint1
            
            prevPoint1 = touch.previousLocationInView(self)
            
            UIGraphicsBeginImageContext(frame.size)
            
            let context = UIGraphicsGetCurrentContext()
            
            CGContextSetAllowsAntialiasing(context, true)
            CGContextSetShouldAntialias(context, true)
            
            CGContextSetLineCap(context, kCGLineCapRound)
            CGContextSetLineWidth(context, brush.brushWidth)
            audio.update()
            CGContextSetStrokeColorWithColor(context, brush.color.CGColor)
            CGContextSetBlendMode(context, kCGBlendModeSoftLight)
            
            
            drawView.image?.drawInRect(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
            
            var mid1 = CGPointMake((prevPoint1.x + prevPoint2.x)*0.5, (prevPoint1.y + prevPoint2.y)*0.5)
            var mid2 = CGPointMake((currentPoint.x + prevPoint1.x)*0.5, (currentPoint.y + prevPoint1.y)*0.5)
            
            CGContextMoveToPoint(context, mid1.x, mid1.y)
            
            CGContextAddQuadCurveToPoint(context, prevPoint1.x, prevPoint1.y, mid2.x, mid2.y)
            
            CGContextStrokePath(context)
            
            drawView.image = UIGraphicsGetImageFromCurrentImageContext()
            
            drawView.alpha = brush.opacity
            
            UIGraphicsEndImageContext()
            
            lastPoint = currentPoint
        }
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchesEnded(touches!, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        UIGraphicsBeginImageContext(canvasView.frame.size)

        canvasView.image?.drawInRect(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        
        drawView.image?.drawInRect(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), blendMode: kCGBlendModeNormal, alpha: brush.opacity)
        
        canvasView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        drawView.image = nil
        
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        //Update audio
        audio.update()
        println(audio.amplitude)
        if (audio.amplitude > audio.noiseFloor) {
            brush.color = palette.getColor(audio.frequency)
        }
    }
    
    // New Drawing Action
    @IBAction func newDrawing(sender: UIButton) {
        canvasView.image = nil
        setNeedsDisplay()
        
    }

    // Interface view/hide actions
    @IBAction func hide(sender: UIButton) {
        show.hidden = false
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    @IBAction func show(sender: UIButton) {
        show.hidden = true
        UIApplication.sharedApplication().statusBarHidden = false
    }

    // Update Palette - Includes update of Brush
    func updatePalette(newPalette: Palette) {
        palette = newPalette
    }
    
}