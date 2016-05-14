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
    var audio: AudioInterface!
    var multiplier: CGFloat = 1
    var minFreq: Double = 100
    var maxFreq: Double = 400
    
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
        palette.addColor(minFreq, color: UIColor.blackColor(), exact: true)
        palette.addColor(maxFreq - 1, color: UIColor.whiteColor(), exact: true)
        palette.addColor(maxFreq, color: UIColor.blackColor(), exact: true)
        
        audio = AudioInterface()
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
            CGContextSetLineWidth(context, (brush.width * multiplier))
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
        
        debugPrint(audio.frequency.average)
        debugPrint(audio.amplitude.average)
        
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
        // Update audio
        audio.update()
        if (audio.amplitude.average > 0.001) {
            brush.color = palette.getColor(audio.frequency!.average)
            multiplier = CGFloat(100 * audio.amplitude.average)
            
            if multiplier > 10 {
                multiplier = 10
            }
            if multiplier < 1 {
                multiplier = 1
            }
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