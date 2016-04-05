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
    var multiplier: Double = 0
    
    //###
    var undoArray = [UIImage] ()
    var redoArray = [UIImage] ()

    @IBOutlet weak var drawView: UIImageView!
    @IBOutlet weak var canvasView: UIImageView!

    
    //variables for points of the quadratic curve
    
    var points = (CGPoint.zero, CGPoint.zero, last: CGPoint.zero)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .whiteColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        palette = Palette()
        palette.addColor(55, color: UIColor.redColor())
        palette.addColor(77, color: UIColor.orangeColor())
        palette.addColor(99, color: UIColor.yellowColor())
        palette.addColor(121, color: UIColor.greenColor())
        palette.addColor(143, color: UIColor.blueColor())
        palette.addColor(165, color: UIColor.purpleColor())
        palette.addColor(187, color: UIColor.redColor())
        palette.addColor(209, color: UIColor.orangeColor())
        palette.addColor(231, color: UIColor.yellowColor())
        palette.addColor(253, color: UIColor.greenColor())
        palette.addColor(275, color: UIColor.blueColor())
        palette.addColor(297, color: UIColor.purpleColor())
        palette.addColor(319, color: UIColor.redColor())
        palette.addColor(341, color: UIColor.orangeColor())
        palette.addColor(363, color: UIColor.yellowColor())
        palette.addColor(385, color: UIColor.greenColor())
        palette.addColor(407, color: UIColor.blueColor())
        palette.addColor(429, color: UIColor.purpleColor())
        palette.addColor(455, color: UIColor.redColor())
        palette.addColor(477, color: UIColor.orangeColor())
        palette.addColor(499, color: UIColor.yellowColor())
        palette.addColor(521, color: UIColor.greenColor())
        palette.addColor(543, color: UIColor.blueColor())
        palette.addColor(565, color: UIColor.purpleColor())
        palette.addColor(587, color: UIColor.redColor())
        palette.addColor(609, color: UIColor.orangeColor())
        palette.addColor(631, color: UIColor.yellowColor())
        palette.addColor(653, color: UIColor.greenColor())
        palette.addColor(675, color: UIColor.blueColor())
        palette.addColor(697, color: UIColor.purpleColor())
        palette.addColor(719, color: UIColor.redColor())
        palette.addColor(741, color: UIColor.orangeColor())
        palette.addColor(763, color: UIColor.yellowColor())
        palette.addColor(785, color: UIColor.greenColor())
        palette.addColor(807, color: UIColor.blueColor())
        palette.addColor(829, color: UIColor.purpleColor())
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            points.0 = touch.previousLocationInView(self)
            
            points.1 = touch.previousLocationInView(self)
            
            points.last = touch.previousLocationInView(self)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            
            let currentPoint = touch.locationInView(self)
            
            points.1 = points.0
            
            points.0 = touch.previousLocationInView(self)
            
            UIGraphicsBeginImageContext(frame.size)
            
            let context = UIGraphicsGetCurrentContext()
            
            CGContextSetAllowsAntialiasing(context, true)
            CGContextSetShouldAntialias(context, true)
            
            CGContextSetLineCap(context, .Round)
            CGContextSetLineWidth(context, brush.width * CGFloat(multiplier))
            CGContextSetStrokeColorWithColor(context, brush.color.CGColor)
            CGContextSetBlendMode(context, .Normal)
            
            
            drawView.image?.drawInRect(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
            
            let mid = ( CGPointMake((points.0.x + points.1.x) * 0.5, (points.0.y + points.1.y) * 0.5),
                        CGPointMake((currentPoint.x + points.0.x)*0.5, (currentPoint.y + points.0.y)*0.5)
            )
            
            CGContextMoveToPoint(context, mid.0.x, mid.0.y)
            CGContextAddQuadCurveToPoint(context, points.0.x, points.0.y, mid.0.x, mid.0.y)
            CGContextAddQuadCurveToPoint(context, points.0.x, points.0.y, mid.1.x, mid.1.y)
            
            CGContextStrokePath(context)
            
            drawView.image = UIGraphicsGetImageFromCurrentImageContext()
            drawView.alpha = brush.opacity
            
            UIGraphicsEndImageContext()
            
            points.last = currentPoint
        }
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>!, withEvent event: UIEvent!) {
        touchesEnded(touches!, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        UIGraphicsBeginImageContext(canvasView.frame.size)
        
        canvasView.image?.drawInRect(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), blendMode: .Normal, alpha: 1.0)
        drawView.image?.drawInRect(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), blendMode: .Normal, alpha: brush.opacity)

        canvasView.image = UIGraphicsGetImageFromCurrentImageContext()
        undoArray.append(UIGraphicsGetImageFromCurrentImageContext())
        UIGraphicsEndImageContext()
        
        drawView.image = nil
        
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        multiplier = audio.amplitude.average * 100 + 1;
        
        // Update audio
        audio.update()
        if (audio.amplitude.average > 0.002) {
            brush.color = palette.getColor(audio.frequency!.average)
        }
    }
    
    // New Drawing Action
    func newDrawing() {
        if canvasView.image != nil {
            undoArray.append(canvasView.image!)
        }
        canvasView.image = nil
        setNeedsDisplay()
        
    }
    
        
    // Update Palette - Includes update of Brush
    func updatePalette(newPalette: Palette) {
        palette = newPalette
    }
    
    func undo() {
        if undoArray.last != nil {
            redoArray.append(undoArray.last!)
            undoArray.removeLast()
            canvasView.image = undoArray.last
        }
    }
    
    func redo() {
        if redoArray.last != nil{
            undoArray.append(redoArray.last!)
            canvasView.image = redoArray.last
            redoArray.removeLast()
        }
    }
    
}