import Foundation
import UIKit

class MenuView : UIView {
    var testColor: UIColor = UIColor(red: 0.5, green:0.0, blue:0.0, alpha: 1.0)
    var image = UIImage()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
            
            
        }
    }
    
    func getColorAtPoint() -> UIColor {
        return testColor
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
        super.touchesBegan(touches, withEvent: event)
        if let touch = touches.first as? UITouch
        {
            let t = touch
            let point = t.locationInView(self)
            println(point)
            testColor = getPixelColorAtPoint(point)//colorAtPosition(point)
            println(testColor)
            
            
        }
    }
}