import Foundation
import UIKit

class PaletteButton: UIButton {
    var frequency: Float! = 0
    var color: UIColor! = UIColor.blackColor()
}

class ColorPickerView: UIImageView {
    var color: UIColor! = UIColor.blackColor()
    var gradientColor: UIColor! = UIColor.blackColor()
}

class PaletteEditorView: UIView {
    var paletteView: UIView = UIView()
    var palette: Palette = Palette()
    var colorPickerView: ColorPickerView = ColorPickerView()
    var gradientView: UIView?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    required init(frame: CGRect, palette: Palette) {
        super.init(frame: frame)
        self.palette = palette
        self.gradientView = UIView(frame: CGRectMake(0, 0, self.frame.width, 50))
        
        self.drawPaletteEditor(palette)
        debugPrint("Palette init(frame, palette) finished (PaletteEditorView:32)")
    }
    
    func open() {
        UIView.animateWithDuration(0.7, animations: {
            var menuFrame = self.frame
            menuFrame.origin.x += menuFrame.size.width
            
            self.frame = menuFrame
            }
        )
    }
    
    func close() {
        UIView.animateWithDuration(0.7, animations: {
            var frame = self.frame
            frame.origin.x -= frame.size.width
            
            self.frame = frame
            }, completion: { finished in
                self.removeFromSuperview()
            }
        )
    }
    // Returns the color data of the pixel at the currently selected point
    func getPixelColorAtPoint(point: CGPoint) -> UIColor? {
        // Capture pixel color data from the background image
        if let pixel = UnsafeMutablePointer<CUnsignedChar>.alloc(4) as UnsafeMutablePointer! {
        
            var ret = UIColor.blackColor()
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
            let context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)
        
            CGContextTranslateCTM(context, -point.x, -point.y)
            self.layer.renderInContext(context!)
            let color: UIColor = UIColor(red: CGFloat(pixel[0])/255.0, green: CGFloat(pixel[1])/255.0, blue: CGFloat(pixel[2])/255.0, alpha: CGFloat(pixel[3])/255.0)
            pixel.dealloc(4)
            ret = color
            return ret
        }
        else {
            debugPrint("Return value not set in ViewController.getPixelColorAtPoint()")
        }
    }
    
    func drawPaletteView(mappings: Array<(Float, UIColor)>) -> UIView {
        
        paletteView = UIView()
        var i: Int = 0
        var xOrigin: CGFloat = 10
        var yOrigin: CGFloat = 0
        
        for (f, c) in mappings {
            
            // Ignore the default mappings for 0Hz and 20kHz
            if f < 1 || f > 19999 {
                continue
            }
            
            if i % 2 == 0 {
                xOrigin = 10
                yOrigin = CGFloat(i * 20)
            }
            else {
                xOrigin = 110
            }
            
            let colorView = UIView(frame: CGRectMake(xOrigin, yOrigin, 100, 30))
            colorView.backgroundColor = UIColor.clearColor()
            
            let delete = PaletteButton(frame: CGRectMake(0, 0, 40, 30))
            delete.backgroundColor = UIColor.clearColor()
            delete.setTitle("-", forState: UIControlState.Normal)
            
            delete.frequency = f
            delete.addTarget(self, action: "deleteMapping:", forControlEvents: UIControlEvents.TouchUpInside)
            colorView.addSubview(delete)
            
            let color = UILabel(frame: CGRectMake(50, 0, 50, 30))
            color.backgroundColor = c
            color.text = Int(f).description
            color.textAlignment = .Center
            colorView.addSubview(color)
            
            i = (i + 1)
            paletteView.addSubview(colorView)
        }
        
        paletteView.frame = CGRectMake(0, 0, 120, CGFloat(i * 35))
        
        return paletteView
    }
    
    func deleteMapping(sender: PaletteButton) {
        palette.deleteColor(sender.frequency)
        drawPaletteView(self.palette.getMappings().sort(<))
        
    }
    func updateColorPicker(color: UIColor, gradientView: UIView, isGradient: Bool) {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.startPoint = CGPointMake(0.0, 0.5)
        gradient.endPoint = CGPointMake(1.0, 0.5)
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.whiteColor().CGColor, color.CGColor, UIColor.blackColor().CGColor]
        gradientView.layer.insertSublayer(gradient, atIndex: 0)
        colorPickerView.addSubview(gradientView)
    }
    
    func drawPaletteEditor(palette: Palette) {
        // This is bad, AND copied from drawMenu.
        // Welcome to All Nighter 2: Electric Bugaloo
        self.backgroundColor = UIColor.clearColor()
        self.alpha = 1
        self.tag = 200
        self.userInteractionEnabled = true
        self.layer.shadowOffset = CGSize(width: 3, height: -2)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 2
        
        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        addSubview(blurEffectView)
        
        
        let title = UILabel(frame: CGRectMake(10, 0, 230, 40))
        title.text = "Palette Editor"
        title.backgroundColor = UIColor.clearColor()
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor.whiteColor()
        self.addSubview(title)
        
        let mappingScrollView = UIScrollView(frame: CGRectMake(0, 270, 250, self.frame.width))
            
        let mappings = palette.getMappings().sort(<)
        let colorView = drawPaletteView(mappings)
        colorView.tag = 2000
            
        mappingScrollView.contentSize = colorView.frame.size
        mappingScrollView.addSubview(colorView)
        mappingScrollView.tag = 300
        
        let colorPicker = ColorPickerView()
        colorPicker.tag = 3000
        
        colorPicker.frame = CGRectMake(0, 0, self.frame.width, 200)
        
        UIGraphicsBeginImageContext(CGSize(width: self.frame.width, height: 180))
        UIImage(named: "colormap.png")!.drawInRect(CGRectMake(colorPicker.frame.origin.x, colorPicker.frame.origin.y + 35, colorPicker.frame.width, colorPicker.frame.height))
        
        colorPicker.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        updateColorPicker(colorPicker.gradientColor, gradientView: gradientView!, isGradient: false)
        colorPicker.addSubview(gradientView!)
        
        let add = PaletteButton(frame: CGRectMake(10, 225 + 30, 230, 40))
        
        add.backgroundColor = UIColor.clearColor()
        add.setTitle("Add", forState: UIControlState.Normal)
        add.addTarget(self, action: "addMapping", forControlEvents: UIControlEvents.TouchUpInside)
        add.backgroundColor = UIColor.blackColor()
        add.tag = 2010
        add.color = colorPicker.color
            
        self.addSubview(add)
        self.addSubview(colorPicker)
        self.addSubview(mappingScrollView)
            
        let menuSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                action: "closeMenu")
        menuSwipeGestureRecognizer.direction = .Left
        self.addGestureRecognizer(menuSwipeGestureRecognizer)
    }
}