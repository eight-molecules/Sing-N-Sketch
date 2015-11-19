import UIKit

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
        if let viewWithTag = self.view.viewWithTag(100) {
            closeMenu()
        }
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
    
    func drawMenu() {
        sketchingView.userInteractionEnabled = false
        
        if let menuView = self.view.viewWithTag(100) {
            closeMenu()
        }
        else {
            // This is bad. All of this is bad, and will be updated to be better.
            let menuView = MenuView(frame: CGRectMake(-250, 0, 250, 1000))
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
            
            if show.hidden != true {
                let title = UILabel(frame: CGRectMake(10, 0, 230, 40))
                title.text = navTitle
                title.backgroundColor = UIColor.clearColor()
                title.textAlignment = NSTextAlignment.Center
                title.textColor = UIColor.whiteColor()
                menuView.addSubview(title)
            }
            
            // Like look at all this. I'm creating a MenuItem with an embedded derivative of UIView
            let save   = UIButton() as UIButton
            save.frame = CGRectMake(10, 40, 110, 50)
            save.backgroundColor = UIColor(white: 0.1, alpha: 0.3)
            save.setTitle("Save", forState: UIControlState.Normal)
            save.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
            save.layer.shadowOffset = CGSize(width: 0, height: 2)
            save.layer.shadowOpacity = 0.7
            save.layer.shadowRadius = 2
            menuView.addSubview(save)
            
            // This could totally be embedded in a class. MenuItem.item -> UIView?
            let new   = UIButton() as UIButton
            new.frame = CGRectMake(130, 40, 110, 50)
            new.backgroundColor = UIColor(white: 0.1, alpha: 0.3)
            new.setTitle("New", forState: UIControlState.Normal)
            new.addTarget(self, action: "new:", forControlEvents: UIControlEvents.TouchUpInside)
            new.layer.shadowOffset = CGSize(width: 0, height: 2)
            new.layer.shadowOpacity = 0.7
            new.layer.shadowRadius = 2
            menuView.addSubview(new)
            
            let undo   = UIButton() as UIButton
            undo.frame = CGRectMake(10, 220, 110, 50)
            undo.backgroundColor = UIColor(white: 0.1, alpha: 0.3)
            undo.setTitle("Undo", forState: UIControlState.Normal)
            undo.addTarget(self, action: "undo:", forControlEvents: UIControlEvents.TouchUpInside)
            undo.layer.shadowOffset = CGSize(width: 0, height: 2)
            undo.layer.shadowOpacity = 0.7
            undo.layer.shadowRadius = 2
            menuView.addSubview(undo)
            
            let redo   = UIButton() as UIButton
            redo.frame = CGRectMake(130, 220, 110, 50)
            redo.backgroundColor = UIColor(white: 0.1, alpha: 0.3)
            redo.setTitle("Redo", forState: UIControlState.Normal)
            redo.addTarget(self, action: "redo:", forControlEvents: UIControlEvents.TouchUpInside)
            redo.layer.shadowOffset = CGSize(width: 0, height: 2)
            redo.layer.shadowOpacity = 0.7
            redo.layer.shadowRadius = 2
            menuView.addSubview(redo)
            
            // Can you just call MenuItem.item as UIButton if you know it's a button?
            let width = UIView(frame: CGRectMake(10, 100, 230, 50))
            let widthSlider = UISlider(frame: CGRectMake(80, 0, 140, 50))
            let widthLabel = UILabel(frame: CGRectMake(10, 0, 60, 50))
            
            width.backgroundColor = UIColor(white: 0.1, alpha: 0.3)
            width.layer.shadowOffset = CGSize(width: 0, height: 2)
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
            let opacity = UIView(frame: CGRectMake(10, 160, 230, 50))
            let opacitySlider = UISlider(frame: CGRectMake(80, 0, 140, 50))
            let opacityLabel = UILabel(frame: CGRectMake(10, 0, 60, 50))
            
            opacity.backgroundColor = UIColor(white: 0.1, alpha: 0.3)
            opacity.layer.shadowOffset = CGSize(width: 0, height: 2)
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

