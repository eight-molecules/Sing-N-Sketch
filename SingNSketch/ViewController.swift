import UIKit

extension Dictionary {
    
    func sort(isOrderedBefore: (Key, Key) -> Bool) -> [(Key, Value)] {
        var result: [(Key, Value)] = []
        let sortedKeys = keys.array.sorted(isOrderedBefore)
        for key in sortedKeys {
            result.append(key, self[key]!)
        }
        return result
    }
}

class PaletteButton: UIButton {
    var frequency: Float! = 0
    var color: UIColor! = UIColor.blackColor()
}

class ColorPickerView: UIImageView {
    var color: UIColor! = UIColor.blackColor()
    var gradientColor: UIColor! = UIColor.blackColor()
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var sketchingView: SketchingView!
    @IBOutlet weak var canvasView: UIImageView!
    @IBOutlet weak var menuView: MenuView!
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    
    @IBOutlet weak var show: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var new: UIButton!
    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var redo: UIButton!
    @IBOutlet weak var navBarLabel: UINavigationItem!
    var navTitle: String = "Sing N' Sketch"
    
    var gradient: CAGradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sketchingView.frame = view.bounds
        sketchingView.autoresizingMask = view.autoresizingMask
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
            action: "swipeMenu:")
        
        
        screenEdgeRecognizer.edges = .Left
        sketchingView.addGestureRecognizer(screenEdgeRecognizer)
        navBarLabel.title = navTitle
        
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.7
        self.navigationController?.navigationBar.layer.shadowRadius = 2
    }
    
    override func viewDidAppear(animated: Bool) {
        sketchingView.audio.start()
        sketchingView.audio.update()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        show.addGestureRecognizer(longPress)
    }
    
    override func viewWillDisappear(animated: Bool) {
        sketchingView.audio.stop()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //returns the color data of the pixel at the currently selected point
    func getPixelColorAtPoint(point:CGPoint)->UIColor?
    {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, bitmapInfo)
        
        CGContextTranslateCTM(context, -point.x, -point.y)
        if let paletteEditor = self.view.viewWithTag(200){
            self.view.viewWithTag(200)!.layer.renderInContext(context)
            var color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0, green: CGFloat(pixel[1])/255.0, blue: CGFloat(pixel[2])/255.0, alpha: CGFloat(pixel[3])/255.0)
            pixel.dealloc(4)
            return color
        }
        return nil
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if let touch = touches.first as? UITouch
        {
            let t = touch
            let point = t.locationInView(self.view.viewWithTag(200)?.viewWithTag(3000))
            if 0.0 <= point.x && point.x <= 250{
                if 39.0 <= point.y && point.y <= 200{
                    var color = getPixelColorAtPoint(point)//colorAtPosition(point)
                    updateColorPicker(color!, isGradient: false)
                }
                else if 200 <= point.y && point.y <= 219 + 30{
                    var color = getPixelColorAtPoint(point)//colorAtPosition(point)
                    updateColorPicker(color!, isGradient: true)
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        if let touch = touches.first as? UITouch
        {
            let t = touch
            let point = t.locationInView(self.view.viewWithTag(200)?.viewWithTag(3000))
            if 0.0 <= point.x && point.x <= 250{
                if 39.0 <= point.y && point.y <= 200{
                    var color = getPixelColorAtPoint(point)//colorAtPosition(point)
                    updateColorPicker(color!, isGradient: false)
                }
                else if 200 <= point.y && point.y <= 219 + 30{
                    var color = getPixelColorAtPoint(point)//colorAtPosition(point)
                    updateColorPicker(color!, isGradient: true)
                }
            }
        }
    }
    
    @IBAction func save(sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(canvasView.image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    func hide(sender: UIButton) {
        navigationController!.navigationBarHidden = true
        show.hidden = false
        
        // Close the menu if it's in the view
        if let menuView = self.view.viewWithTag(100) {
            let title = UILabel(frame: CGRectMake(10, 0, 230, 40))
            title.text = navTitle
            title.backgroundColor = UIColor.clearColor()
            title.textAlignment = NSTextAlignment.Center
            title.textColor = UIColor.whiteColor()
            menuView.addSubview(title)
            
        }
        // Close the Palette Editor if it's in the view.
        if let paletteEditor = self.view.viewWithTag(200) {
            UIView.animateWithDuration(0.7, animations: {
                var frame = paletteEditor.frame
                frame.origin.x -= frame.size.width
                
                paletteEditor.frame = frame
                }, completion: { finished in
                    paletteEditor.removeFromSuperview()
                }
            )
            sketchingView.userInteractionEnabled = true
        }

    }
    
    @IBAction func show(sender: UIButton) {
        navigationController!.navigationBarHidden = false
        show.hidden = true
    }
    
    func handleLongPress(longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .Changed:
            let point = longPress.locationInView(view)
            show.center = point
        default:
            break
            
        }
    }
    
    func getPaletteView() -> UIView {
        let mappings = sketchingView.palette.getMappings().sort(<)
        
        let paletteView = UIView()
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
            delete.addTarget(self, action: "deleteMapping:", forControlEvents: UIControlEvents.TouchUpInside)
            delete.frequency = f
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
    
    func updatePaletteView() {
        if let paletteEditor = self.view.viewWithTag(200) {
            if let scrollView = paletteEditor.viewWithTag(300) {
                if var paletteView = scrollView.viewWithTag(2000) {
                    paletteView.removeFromSuperview()
                    paletteView = getPaletteView()
                    paletteView.tag = 2000
                    scrollView.addSubview(paletteView)
                }
            }
        }
    }
    func updateColorPicker(color: UIColor, isGradient: Bool) {
        if let paletteEditor = self.view.viewWithTag(200) {
            if var colorPicker = paletteEditor.viewWithTag(3000) as? ColorPickerView {
                let add = paletteEditor.viewWithTag(2010) as! UIButton
                
                colorPicker.color = color
                if(isGradient == false){
                    colorPicker.gradientColor = color
                }
                
                var gradientView: UIView = UIView(frame: CGRectMake(colorPicker.frame.origin.x, colorPicker.frame.origin.y + colorPicker.frame.height, colorPicker.frame.width, 20 + 30))
                gradient.startPoint = CGPointMake(0.0, 0.5)
                gradient.endPoint = CGPointMake(1.0, 0.5)
                gradient.frame = gradientView.bounds
                gradient.colors = [UIColor.whiteColor().CGColor, colorPicker.gradientColor.CGColor, UIColor.blackColor().CGColor]
                gradientView.layer.insertSublayer(gradient, atIndex: 0)
                colorPicker.addSubview(gradientView)
                
                add.backgroundColor = colorPicker.color
            }
        }
    }
    
    func drawPaletteEditor() {
        closeMenu()
        sketchingView.userInteractionEnabled = false
        
        var offset = (x: 0, y: self.navigationController!.navigationBar.frame.height + 5)
        
        // This should never run. If it does, something called the wrong function
        if let paletteEditor = self.view.viewWithTag(200) {
            UIView.animateWithDuration(0.7, animations: {
                var frame = paletteEditor.frame
                frame.origin.x -= frame.size.width
                
                paletteEditor.frame = frame
                }, completion: { finished in
                    paletteEditor.removeFromSuperview()
                }
            )
            sketchingView.userInteractionEnabled = true
        }
        else {
            
            // This is bad, AND copied from drawMenu.
            // Welcome to All Nighter 2: Electric Bugaloo
            let menuView = MenuView(frame: CGRectMake(-250, 0, 250, self.view.frame.height))
            menuView.backgroundColor = UIColor.clearColor()
            menuView.alpha = 1
            menuView.tag = 200
            menuView.userInteractionEnabled = true
            menuView.layer.shadowOffset = CGSize(width: 3, height: -2)
            menuView.layer.shadowOpacity = 0.7
            menuView.layer.shadowRadius = 2
            
            // Blur Effect
            var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            var blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = menuView.bounds
            menuView.addSubview(blurEffectView)
            
            if show.hidden == false {
                offset.y = 0
                
                let title = UILabel(frame: CGRectMake(10, 0, 230, 40))
                title.text = "Palette Editor"
                title.backgroundColor = UIColor.clearColor()
                title.textAlignment = NSTextAlignment.Center
                title.textColor = UIColor.whiteColor()
                menuView.addSubview(title)
                
            }
            
            let scrollView = UIScrollView(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.height + 240 + 30, 250, CGFloat(self.view.frame.height - (self.navigationController!.navigationBar.frame.height + 230))))
            let colorView = getPaletteView()
            colorView.tag = 2000
            
            scrollView.contentSize = colorView.frame.size
            scrollView.addSubview(colorView)
            scrollView.tag = 300
            let colorPicker = ColorPickerView()
            colorPicker.tag = 3000
            
            colorPicker.frame = CGRectMake(0, 0, menuView.frame.width, 200)
            
            UIGraphicsBeginImageContext(CGSize(width: menuView.frame.width, height: 180))
            UIImage(named: "colormap.png")!.drawInRect(CGRectMake(colorPicker.frame.origin.x, colorPicker.frame.origin.y + 35, colorPicker.frame.width, colorPicker.frame.height))
            colorPicker.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            var gradientView: UIView = UIView(frame: CGRectMake(colorPicker.frame.origin.x, colorPicker.frame.origin.y + colorPicker.frame.height, colorPicker.frame.width, 20 + 30))
            gradient.startPoint = CGPointMake(0.0, 0.5)
            gradient.endPoint = CGPointMake(1.0, 0.5)
            gradient.frame = gradientView.bounds
            gradient.colors = [UIColor.whiteColor().CGColor, colorPicker.gradientColor.CGColor, UIColor.blackColor().CGColor]
            gradientView.layer.insertSublayer(gradient, atIndex: 0)
            colorPicker.addSubview(gradientView)
            
            let add = PaletteButton(frame: CGRectMake(10, 225 + 30, 230, 40))
            
            add.backgroundColor = UIColor.clearColor()
            add.setTitle("Add", forState: UIControlState.Normal)
            add.addTarget(self, action: "addMapping", forControlEvents: UIControlEvents.TouchUpInside)
            add.backgroundColor = sketchingView.brush.color
            add.tag = 2010
            add.color = colorPicker.color
            
            menuView.addSubview(add)
            menuView.addSubview(colorPicker)
            menuView.addSubview(scrollView)
            
            let menuSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                action: "closeMenu")
            menuSwipeGestureRecognizer.direction = .Left
            menuView.addGestureRecognizer(menuSwipeGestureRecognizer)
            
            self.view.addSubview(menuView)
            
            UIView.animateWithDuration(0.7, animations: {
                var menuFrame = menuView.frame
                menuFrame.origin.x += menuFrame.size.width
                
                menuView.frame = menuFrame
                }
            )
        }
        
    }
    
    func deleteMapping(sender: PaletteButton) {
        sketchingView.palette.deleteColor(sender.frequency)
        updatePaletteView()
    }
    
    func addMapping() {
        if let paletteEditor = self.view.viewWithTag(200) {
            if let colorPicker = paletteEditor.viewWithTag(3000) as? ColorPickerView {
                for i in 1...25 {
                    sketchingView.audio.update()
                }
                sketchingView.palette.addColor(sketchingView.audio.frequency.average, color: colorPicker.color)
                updatePaletteView()
            }
        }
    }
    
    
    func drawMenu() {
        sketchingView.userInteractionEnabled = false
        
        var offset = (x: 0, y: self.navigationController!.navigationBar.frame.height)
        if let menuView = self.view.viewWithTag(100) {
            closeMenu()
        }
        else if let paletteEditorView = self.view.viewWithTag(200) {
            closeMenu()
        }
        else {
            
            // This is bad. All of this is bad, and will be updated to be better.
            let menuView = MenuView(frame: CGRectMake(-250, 0, 250, self.view.frame.height))
            menuView.backgroundColor = UIColor.clearColor()
            menuView.alpha = 1
            menuView.tag = 100
            menuView.userInteractionEnabled = true
            menuView.layer.shadowOffset = CGSize(width: 3, height: -2)
            menuView.layer.shadowOpacity = 0.7
            menuView.layer.shadowRadius = 2
            
            // Blur Effect
            var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            var blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = menuView.bounds
            menuView.addSubview(blurEffectView)
            
            if show.hidden == false {
                offset.y = 0
                
                let title = UILabel(frame: CGRectMake(10, 0, 230, 40))
                title.text = navTitle
                title.backgroundColor = UIColor.clearColor()
                title.textAlignment = NSTextAlignment.Center
                title.textColor = UIColor.whiteColor()
                menuView.addSubview(title)
                
            }
            
            // Can you just call MenuItem.item as UIButton if you know it's a button?
            let width = UIView(frame: CGRectMake(10, 40 + offset.y, 230, 40))
            let widthSlider = UISlider(frame: CGRectMake(80, 0, 140, 40))
            let widthLabel = UILabel(frame: CGRectMake(10, 0, 60, 40))
            
            width.backgroundColor = UIColor(white: 0.1, alpha: 0)
            width.layer.shadowOffset = CGSize(width: 0, height: 1)
            width.layer.shadowOpacity = 0.7
            width.layer.shadowRadius = 2
            
            widthLabel.text = "Width"
            widthLabel.textColor = UIColor.whiteColor()
            widthLabel.textAlignment = NSTextAlignment.Center
            
            widthSlider.minimumValue = 1
            widthSlider.maximumValue = 50
            widthSlider.continuous = true
            widthSlider.value = Float(sketchingView.brush.width)
            widthSlider.addTarget(self, action: "widthManipulator:", forControlEvents: .ValueChanged)
            
            width.addSubview(widthSlider)
            width.addSubview(widthLabel)
            menuView.addSubview(width)
            
            // TODO: Look up generic storage and type checking
            let opacity = UIView(frame: CGRectMake(10, 90 + offset.y, 230, 40))
            let opacitySlider = UISlider(frame: CGRectMake(80, 0, 140, 40))
            let opacityLabel = UILabel(frame: CGRectMake(10, 0, 60, 40))
            
            opacity.backgroundColor = UIColor(white: 0.1, alpha: 0)
            opacity.layer.shadowOffset = CGSize(width: 0, height: 1)
            opacity.layer.shadowOpacity = 0.7
            opacity.layer.shadowRadius = 2
            
            opacityLabel.text = "Opacity"
            opacityLabel.textColor = UIColor.whiteColor()
            opacityLabel.textAlignment = NSTextAlignment.Center
            
            opacitySlider.minimumValue = 0
            opacitySlider.maximumValue = 1
            opacitySlider.continuous = true
            opacitySlider.value = Float(sketchingView.brush.opacity)
            opacitySlider.addTarget(self, action: "opacityManipulator:", forControlEvents: .ValueChanged)
            
            opacity.addSubview(opacitySlider)
            opacity.addSubview(opacityLabel)
            menuView.addSubview(opacity)
            
            // Like look at all this. I'm creating a MenuItem with an embedded derivative of UIView
            let save   = UIButton() as UIButton
            save.frame = CGRectMake(10, 140 + offset.y, 110, 40)
            save.backgroundColor = UIColor(white: 0.1, alpha: 0)
            save.setTitle("Save", forState: UIControlState.Normal)
            save.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
            save.layer.shadowOffset = CGSize(width: 0, height: 1)
            save.layer.shadowOpacity = 0.7
            save.layer.shadowRadius = 2
            menuView.addSubview(save)
            
            // This could totally be embedded in a class. MenuItem.item -> UIView?
            let new   = UIButton() as UIButton
            new.frame = CGRectMake(130, 140 + offset.y, 110, 40)
            new.backgroundColor = UIColor(white: 0.1, alpha: 0)
            new.setTitle("New", forState: UIControlState.Normal)
            new.addTarget(self, action: "new:", forControlEvents: UIControlEvents.TouchUpInside)
            new.layer.shadowOffset = CGSize(width: 0, height: 1)
            new.layer.shadowOpacity = 0.7
            new.layer.shadowRadius = 2
            menuView.addSubview(new)
            
            let undo   = UIButton() as UIButton
            undo.frame = CGRectMake(10, 190 + offset.y, 110, 40)
            undo.backgroundColor = UIColor(white: 0.1, alpha: 0)
            undo.setTitle("Undo", forState: UIControlState.Normal)
            undo.addTarget(self, action: "undo:", forControlEvents: UIControlEvents.TouchUpInside)
            undo.layer.shadowOffset = CGSize(width: 0, height: 1)
            undo.layer.shadowOpacity = 0.7
            undo.layer.shadowRadius = 2
            menuView.addSubview(undo)
            
            let redo   = UIButton() as UIButton
            redo.frame = CGRectMake(130, 190 + offset.y, 110, 40)
            redo.backgroundColor = UIColor(white: 0.1, alpha: 0)
            redo.setTitle("Redo", forState: UIControlState.Normal)
            redo.addTarget(self, action: "redo:", forControlEvents: UIControlEvents.TouchUpInside)
            redo.layer.shadowOffset = CGSize(width: 0, height: 1)
            redo.layer.shadowOpacity = 0.7
            redo.layer.shadowRadius = 2
            menuView.addSubview(redo)
            
            let openPaletteEditor   = UIButton() as UIButton
            openPaletteEditor.frame = CGRectMake(10, 240 + offset.y, 230, 40)
            openPaletteEditor.backgroundColor = UIColor(white: 0.1, alpha: 0)
            openPaletteEditor.setTitle("Palette Editor", forState: UIControlState.Normal)
            openPaletteEditor.addTarget(self, action: "drawPaletteEditor", forControlEvents: UIControlEvents.TouchUpInside)
            openPaletteEditor.layer.shadowOffset = CGSize(width: 0, height: 1)
            openPaletteEditor.layer.shadowOpacity = 0.7
            openPaletteEditor.layer.shadowRadius = 2
            menuView.addSubview(openPaletteEditor)
            
            let menuSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                action: "closeMenu")
            menuSwipeGestureRecognizer.direction = .Left
            menuView.addGestureRecognizer(menuSwipeGestureRecognizer)
            
            self.view.addSubview(menuView)
            
            
            UIView.animateWithDuration(0.7, animations: {
                var menuFrame = menuView.frame
                menuFrame.origin.x += menuFrame.size.width
                
                menuView.frame = menuFrame
                }
            )
        }
        
    }
    
    @IBAction func showMenuView(sender: UIBarButtonItem) {
        if let menuView = self.view.viewWithTag(100) {
            closeMenu()
        }
        else {
            drawMenu()
        }
    }
    
    func swipeMenu(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Ended {
            if let menuView = self.view.viewWithTag(100) {
                // Nothing happens if we swipe and the menu is open
            }
            else {
                drawMenu()
            }
        }
    }
    
    func closeMenu() {
        if let menuView = self.view.viewWithTag(100) {
            UIView.animateWithDuration(0.7, animations: {
                var menuFrame = menuView.frame
                menuFrame.origin.x -= menuFrame.size.width
                
                menuView.frame = menuFrame
                }, completion: { finished in
                    menuView.removeFromSuperview()
                }
            )
        }
        else if let paletteEditor = self.view.viewWithTag(200) {
            UIView.animateWithDuration(0.7, animations: {
                var frame = paletteEditor.frame
                frame.origin.x -= frame.size.width
                
                paletteEditor.frame = frame
                }, completion: { finished in
                    paletteEditor.removeFromSuperview()
                }
            )
            
        }
        sketchingView.userInteractionEnabled = true
    }
    
    @IBAction func new(sender: UIButton) {
        sketchingView.newDrawing()
    }
    
    //###
    @IBAction func redo(sender: UIButton) {
        sketchingView.redo()
    }
    
    @IBAction func undo(sender: UIButton) {
        sketchingView.undo()
    }
    
    // Interface slider actions
    @IBAction func opacityManipulator(sender: UISlider) {
        sketchingView.brush.opacity = CGFloat(sender.value)
    }
    
    @IBAction func widthManipulator(sender: UISlider) {
        sketchingView.brush.width = CGFloat(sender.value)
    }
    
    @IBAction func mute(sender: UIButton) {
        AKSettings.shared().audioInputEnabled = false
    }
    
    @IBAction func unmute(sender: UIButton) {
        AKSettings.shared().audioInputEnabled = true
    }
}

