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

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var hide: UIButton!
    @IBOutlet weak var show: UIButton!
    @IBOutlet weak var newDrawing: UIButton!
    
    //stores an array of points for Bezier curves
    var points = [CGPoint]()
    
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
        let touch = touches.first as! UITouch
        points.append(touch.locationInView(self))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        points.append(touch.locationInView(self))
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchesEnded(touches!, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        points.append(touch.locationInView(self))
        
        setNeedsDisplay()
        
        //draws the bezier path to the screen and saves the image in
        //a temporary view to be added to the main view later
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawViewHierarchyInRect(bounds, afterScreenUpdates: true)
        drawImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        points.removeAll()
        
    }
    
    // New Drawing Action
    @IBAction func newDrawing(sender: UIButton) {
        drawImage = nil
        drawImage?.drawInRect(bounds)
        setNeedsDisplay()
        
    }

    // Interface view/hide actions
    @IBAction func hide(sender: UIButton) {
        toolBar.hidden = true
        show.hidden = false
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    @IBAction func show(sender: UIButton) {
        toolBar.hidden = false
        show.hidden = true
        UIApplication.sharedApplication().statusBarHidden = false
    }

    // Update Palette - Includes update of Brush
    func updatePalette(newPalette: Palette) {
        palette = newPalette
    }
    
    // Function that gets the mid point of 
    // a line used for bezier paths.
    func getMidPoint(a: CGPoint, andB b: CGPoint) -> CGPoint{
        return CGPoint(x: (a.x + b.x)/2, y: (a.y + b.y)/2)
    }
    
    
    //Only override drawRect: if you perform custom drawing.
    //An empty implementation adversly affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Update audio
        audio.update()
        
        let context = UIGraphicsGetCurrentContext()
        
        // DEMO CODE - Changes Blue value based on frequency
        if (audio.amplitude > 0.05) {
            brush.color = palette.getColor(audio.frequency)
            var colorSpace = CGColorGetColorSpace(brush.color.CGColor)
            var colorSpaceModel = CGColorSpaceGetModel(colorSpace)
        }
        
        //Drawing code
        //enabling antialiasing
        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetShouldAntialias(context, true)
        
        //creating bezier path
        let path = UIBezierPath()
        let _shapeLayer = CAShapeLayer()
        
        path.lineCapStyle = kCGLineCapRound
        path.lineJoinStyle = kCGLineJoinRound
        path.lineWidth = brush.brushWidth
        
        // Update color of bezier path
        CGContextSetStrokeColorWithColor(context, brush.color.CGColor)
        
        path.removeAllPoints()
        
        //a temporary image view that draws the image and subsequent images to the screen.
        drawImage?.drawInRect(self.bounds)
        
        //draw a line between first point and mid point, then mid point and last point
        //quadratic bezier curves are then made
        if !points.isEmpty {
            path.moveToPoint(points.first!)
            path.addLineToPoint(getMidPoint(points.first!, andB: points[1]))
            var x = Int()
            for index in 1..<points.count - 1 {
                let midPoint = getMidPoint(points[index], andB: points[index+1])
                path.addQuadCurveToPoint(midPoint, controlPoint: points[index])
                x = index
            }
            
            path.addLineToPoint(points.last!)
            
            path.stroke()
        }
        
    }
}
