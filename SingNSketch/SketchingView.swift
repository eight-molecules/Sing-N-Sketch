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
    
    var points = (prevPoint1: CGPoint.zeroPoint, prevPoint2: CGPoint.zeroPoint, lastPoint: CGPoint.zeroPoint)
    
    
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
            points.prevPoint1 = touch.previousLocationInView(self)
            
            points.prevPoint2 = touch.previousLocationInView(self)
            
            points.lastPoint = touch.previousLocationInView(self)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch{
        
            let currentPoint = touch.locationInView(self)
            
            points.prevPoint2 = points.prevPoint1
            
            points.prevPoint1 = touch.previousLocationInView(self)
            
            UIGraphicsBeginImageContext(frame.size)
            
            let context = UIGraphicsGetCurrentContext()
            
            CGContextSetAllowsAntialiasing(context, true)
            CGContextSetShouldAntialias(context, true)
            
            CGContextSetLineCap(context, kCGLineCapRound)
            CGContextSetLineWidth(context, brush.brushWidth)
            CGContextSetStrokeColorWithColor(context, brush.color.CGColor)
            CGContextSetBlendMode(context, kCGBlendModeNormal)
            
            
            drawView.image?.drawInRect(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
            
            var mid1 = CGPointMake((points.prevPoint1.x + points.prevPoint2.x)*0.5, (points.prevPoint1.y + points.prevPoint2.y)*0.5)
            var mid2 = CGPointMake((currentPoint.x + points.prevPoint1.x)*0.5, (currentPoint.y + points.prevPoint1.y)*0.5)
            
            CGContextMoveToPoint(context, mid1.x, mid1.y)
            
            CGContextAddQuadCurveToPoint(context, points.prevPoint1.x, points.prevPoint1.y, mid2.x, mid2.y)
            
            CGContextStrokePath(context)
            
            drawView.image = UIGraphicsGetImageFromCurrentImageContext()
            
            drawView.alpha = brush.opacity
            
            UIGraphicsEndImageContext()
            
            points.lastPoint = currentPoint
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