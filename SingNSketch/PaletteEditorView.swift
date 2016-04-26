import Foundation
import UIKit

class PaletteButton: UIButton {
    var frequency: Double! = 0
    var color: UIColor! = UIColor.blackColor()
}

class ColorPickerView: UIImageView {
    var color: UIColor! = UIColor.blackColor()
    var gradientColor: UIColor! = UIColor.blackColor()
}

class PaletteEditorView: UIView {
    var mappingScrollView: UIScrollView!
    var paletteView: UIView = UIView()
    var palette: Palette!
    var audio: AudioInterface!
    var colorPicker: ColorPickerView!
    var gradientView: UIView!
    
    // Color image for selector
    var colorMap: UIImage {
        UIGraphicsBeginImageContext(CGSize(width: self.frame.width, height: 180))
        UIImage(named: "colormap")!.drawInRect(CGRectMake(colorPicker.frame.origin.x, colorPicker.frame.origin.y + 35, colorPicker.frame.width, colorPicker.frame.height))
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    required init(frame: CGRect, palette: Palette, audio: AudioInterface) {
        super.init(frame: frame)
        
        // Init properties sent from the superview
        self.palette = palette
        self.audio = audio
        
        // Generating views we need data from
        self.colorPicker = ColorPickerView(frame: CGRectMake(0, 0, self.frame.width, 200))
        self.gradientView = UIView(frame: CGRectMake(0, 0, self.frame.width, 50))
        
        // Update UIView attributes
        self.backgroundColor = UIColor.clearColor()
        self.alpha = 1
        self.tag = 200
        self.userInteractionEnabled = true
        self.layer.shadowOffset = CGSize(width: 3, height: -2)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 2
        
        // Apply Blur Effect to background
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
        
        mappingScrollView = generateColorMappingsView()
        
        colorPicker.image = colorMap
        updateColorPicker(colorPicker.gradientColor, view: gradientView, isGradient: false)
        colorPicker.addSubview(gradientView!)
        
        let add = PaletteButton(frame: CGRectMake(10, colorPicker.frame.height, 230, 40))
        
        add.backgroundColor = UIColor.clearColor()
        add.setTitle("Add", forState: UIControlState.Normal)
        add.addTarget(self, action: "addMapping:", forControlEvents: UIControlEvents.TouchUpInside)
        add.backgroundColor = UIColor.blackColor()
        add.tag = 2010
        add.color = colorPicker.color
        add.frequency = audio.clearFrequency()
        
        self.addSubview(add)
        self.addSubview(colorPicker)
        self.addSubview(mappingScrollView)
        
        let menuSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "close")
        menuSwipeGestureRecognizer.direction = .Left
        self.addGestureRecognizer(menuSwipeGestureRecognizer)
        
        debugPrint("Palette init(frame, palette) finished (PaletteEditorView:32)")
    }
    
      // // // // // // //
      //                //
      // Color Picker  //
    ////                // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
    
    // ToDo:
    func updateColorPicker(color: UIColor, view: UIView, isGradient: Bool) {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.startPoint = CGPointMake(0.0, 0.5)
        gradient.endPoint = CGPointMake(1.0, 0.5)
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.whiteColor().CGColor, color.CGColor, UIColor.blackColor().CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        colorPicker.addSubview(gradientView)
    }
    
      // // // // // // //
      //                //
      // Mappings View  //
    ////                // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
    
    func generateColorMappingsView() -> UIScrollView {
        let view = UIScrollView(frame: CGRectMake(0, colorPicker.frame.height + 50, self.frame.height - colorPicker.frame.height + 50, self.frame.width))
        
        let mappings = palette.getMappings().sort(<)
        
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
            view.addSubview(colorView)
        }
        
        return view
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let point = touches.first?.locationInView(colorPicker) {
            colorPicker.color = getPixelColorAtPoint(point)
            
            add.color = colorPicker.color
            add.backgroundColor = colorPicker.color
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let point = touches.first?.locationInView(colorPicker) {
            colorPicker.color = getPixelColorAtPoint(point)
            let add = self.viewWithTag(2010) as! PaletteButton
            add.color = colorPicker.color
            add.backgroundColor = colorPicker.color
        }
    }
    
    // Returns the color data of the pixel at the currently selected point
    
    
    func open() {
        UIView.animateWithDuration(0.7, animations: {
            var menuFrame = self.frame
            debugPrint("Palette Editor Opening")
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
                debugPrint("Palette Editor Closing")
                self.removeFromSuperview()
            }
        )
    }
    
}