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
    var userBrush: Brush = Brush()
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var hide: UIButton!
    @IBOutlet weak var show: UIButton!
    
    //stores an array of points for Bezier curves
    var points = [CGPoint]()
    
    var audio: AudioInterface = AudioInterface()
    
    // Basic pitch mappings. Do not re-use, we have a framework for this.
    let noteFrequencies = [16.35,17.32,18.35,19.45,20.6,21.83,23.12,24.5,25.96,27.5,29.14,30.87]
    let noteNamesWithSharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
    let noteNamesWithFlats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]
    
        @IBOutlet weak var newDrawing: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .whiteColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
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
    
    //function that gets the mid point of a line.
    //used for bezier paths
    func getMidPoint(a: CGPoint, andB b: CGPoint) -> CGPoint{
        return CGPoint(x: (a.x + b.x)/2, y: (a.y + b.y)/2)
    }
    
    
    //Only override drawRect: if you perform custom drawing.
    //An empty implementation adversly affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Update audio
        audio.update()
        
        let currentContext = UIGraphicsGetCurrentContext()
        
        // DEBUG
        let f = "Frequency: " + audio.frequency.description
        let a = "Amplitude: " + audio.amplitude.description
        println(f)
        println(a)
        println("")
        
        // DEMO CODE - Changes Blue value based on frequency
        if (audio.amplitude > 0.005) {
            var frequency: Float = audio.frequency
            while (frequency > Float(noteFrequencies[noteFrequencies.count-1])) {
                frequency = frequency / 2.0
            }
            while (frequency < Float(noteFrequencies[0])) {
                frequency = frequency * 2.0
            }
            
            // Set red color
            let b = CGFloat((frequency - 16) / 16)
            userBrush.blue = b
            
            
        }
        
        //Drawing code
        //enabling antialiasing
        CGContextSetAllowsAntialiasing(currentContext, true)
        CGContextSetShouldAntialias(currentContext, true)
        
        //creating bezier path
        let path = UIBezierPath()
        let _shapeLayer = CAShapeLayer()
        
        path.lineCapStyle = kCGLineCapRound
        path.lineJoinStyle = kCGLineJoinRound
        path.lineWidth = userBrush.brushWidth
        //_shapeLayer.strokeColor = color//UIColor.greenColor().CGColor
        _shapeLayer.fillColor = nil
        _shapeLayer.lineWidth = 3
        //_shapeLayer.path = path.CGPath
        //_shapeLayer.lineCap = kCALineCapRound
        //layer.addSublayer(_shapeLayer)
        
        //creates the components that update the color of the bezier path
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = [userBrush.red, userBrush.green, userBrush.blue, userBrush.opacity]
        let color = CGColorCreate(colorSpace, components)
        CGContextSetStrokeColorWithColor(currentContext, color)
        
        path.removeAllPoints()
        
        //a temporary image view that draws the image and subsequent images to the screen.
        drawImage?.drawInRect(bounds)
        
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
            
            if(x % 2 ~= 0){
                //_shapeLayer.strokeColor = UIColor.redColor().CGColor
                _shapeLayer.strokeColor = color
            }
            
            _shapeLayer.path = path.CGPath
            _shapeLayer.lineCap = kCALineCapRound
            _shapeLayer.strokeStart = 0.9
            //path.stroke()
            layer.addSublayer(_shapeLayer)
            path.stroke()
            _shapeLayer.strokeEnd = 1.0
            //path.closePath()
            //_shapeLayer.path = path.CGPath
        }
        
    }
}
