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

class PaletteAddButton: UIButton {
    var frequency: Float! = 0
    var color: UIColor! = UIColor.clearColor()
}

class PaletteDeleteButton: UIButton {
    var frequency: Float! = 0
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
        if let menuView = self.view.viewWithTag(100) {
            let title = UILabel(frame: CGRectMake(10, 0, 230, 40))
            title.text = navTitle
            title.backgroundColor = UIColor.clearColor()
            title.textAlignment = NSTextAlignment.Center
            title.textColor = UIColor.whiteColor()
            menuView.addSubview(title)

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
        var i: CGFloat = 0
        for (f, c) in mappings {
            
            // Ignore the default mappings for 0Hz and 20kHz
            if f < 1 || f > 19999 {
                continue
            }
            
            let yOrigin = i * 35
            let colorView = UIView(frame: CGRectMake(10, yOrigin, 100, 30))
            colorView.backgroundColor = UIColor.clearColor()
            
            let delete = PaletteDeleteButton(frame: CGRectMake(0, 0, 60, 30))
            delete.backgroundColor = UIColor.clearColor()
            delete.setTitle("Delete", forState: UIControlState.Normal)
            delete.addTarget(self, action: "deleteMapping:", forControlEvents: UIControlEvents.TouchUpInside)
            delete.frequency = f
            colorView.addSubview(delete)
            
            let color = UILabel(frame: CGRectMake(70, 0, 70, 30))
            color.backgroundColor = c
            color.text = Int(f).description
            color.textAlignment = .Center
            colorView.addSubview(color)
            
            i = (i + 1)
            paletteView.addSubview(colorView)
        }
        
        paletteView.frame = CGRectMake(0, self.navigationController!.navigationBar.frame.height + 200, 120, i * 35)
        
        return paletteView
    }
    
    func updatePaletteView() {
        if let paletteEditor = self.view.viewWithTag(200) {
            if var paletteView = paletteEditor.viewWithTag(2000) {
                paletteView.removeFromSuperview()
                paletteView = getPaletteView()
                paletteView.tag = 2000
                paletteEditor.addSubview(paletteView)
            }
        }
    }

    
    func drawPaletteEditor() {
        closeMenu()
        sketchingView.userInteractionEnabled = false
        
        var offset = (x: 0, y: self.navigationController!.navigationBar.frame.height + 5)
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
                
                let title = UILabel(frame: CGRectMake(10, 0 + (offset.y / 2), 230, 40))
                title.text = "Palette Editor"
                title.backgroundColor = UIColor.clearColor()
                title.textAlignment = NSTextAlignment.Center
                title.textColor = UIColor.whiteColor()
                menuView.addSubview(title)
                
            }
            
            let colorView = getPaletteView()
            colorView.tag = 2000
            
            menuView.addSubview(colorView)
            
            self.view.addSubview(menuView)

            UIView.animateWithDuration(0.7, animations: {
                var menuFrame = menuView.frame
                menuFrame.origin.x += menuFrame.size.width
                
                menuView.frame = menuFrame
                }
            )
        }
        
    }
    
    func deleteMapping(sender: PaletteDeleteButton) {
        sketchingView.palette.deleteColor(sender.frequency)
        updatePaletteView()
    }
    
    func addMapping(sender: PaletteAddButton) {
        sketchingView.palette.addColor(sender.frequency, color: sender.color)
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

