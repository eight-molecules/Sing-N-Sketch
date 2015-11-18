import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var sketchingView: SketchingView!
    @IBOutlet weak var canvasView: UIImageView!
    @IBOutlet weak var menuView: MenuView!
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    
    @IBOutlet weak var hide: UIBarButtonItem!
    @IBOutlet weak var show: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var new: UIButton!
    @IBOutlet weak var navBarLabel: UINavigationItem!
    
    var navTitle: String = "Sing N' Sketch"
    
    var audio: AudioInterface = AudioInterface()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sketchingView.frame = view.bounds
        sketchingView.autoresizingMask = view.autoresizingMask
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
            action: "swipeMenu:")
        screenEdgeRecognizer.edges = .Left
        view.addGestureRecognizer(screenEdgeRecognizer)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        sketchingView.audio.start()
        sketchingView.audio.update()
        
        // This is bad. All of this is bad, and will be updated to be better.
        var barView = UIView(frame: CGRectMake(0, 30, 250, 1000))
        barView.backgroundColor = UIColor.clearColor()
        barView.alpha = 1
        
        let navBarItems = UIBarButtonItem() as UIBarButtonItem!
        navBarItems.customView = barView
        
        var hideButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Hide", style: UIBarButtonItemStyle.Plain, target: self, action: "hide:")
        self.title = navTitle
        
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
            viewWithTag.removeFromSuperview()
        }
        navigationController!.navigationBarHidden = true
        show.hidden = false
        if let menuView = self.view.viewWithTag(100) {
            closeMenu()
        }
    }
    
    @IBAction func show(sender: UIButton) {
        navigationController!.navigationBarHidden = false
        show.hidden = true
        //###
        sketchingView.undo()
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
        if let menuView = self.view.viewWithTag(100) {
            closeMenu()
        }
        else {
            // This is bad. All of this is bad, and will be updated to be better.
            let menuView = MenuView(frame: CGRectMake(-250, 30, 250, 1000))
            menuView.backgroundColor = UIColor.grayColor()
            menuView.alpha = 1
            menuView.tag = 100
            menuView.userInteractionEnabled = true
            menuView.layer.shadowOffset = CGSize(width: 3, height: 0)
            menuView.layer.shadowOpacity = 0.7
            menuView.layer.shadowRadius = 2
            
            
            // Like look at all this. I'm creating a MenuItem with an embedded derivative of UIView
            let save   = UIButton() as UIButton
            save.frame = CGRectMake(10, self.navigationController!.navigationBar.frame.height, 110, 50)
            save.backgroundColor = UIColor.darkGrayColor()
            save.setTitle("Save", forState: UIControlState.Normal)
            save.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
            save.layer.shadowOffset = CGSize(width: 0, height: 2)
            save.layer.shadowOpacity = 0.7
            save.layer.shadowRadius = 2
            menuView.addSubview(save)
            
            // This could totally be embedded in a class. MenuItem.item -> UIView?
            let new   = UIButton() as UIButton
            new.frame = CGRectMake(130, self.navigationController!.navigationBar.frame.height, 110, 50)
            new.backgroundColor = UIColor.darkGrayColor()
            new.setTitle("Clear", forState: UIControlState.Normal)
            new.addTarget(self, action: "new:", forControlEvents: UIControlEvents.TouchUpInside)
            new.layer.shadowOffset = CGSize(width: 0, height: 2)
            new.layer.shadowOpacity = 0.7
            new.layer.shadowRadius = 2
            menuView.addSubview(new)
            
            // Can you just call MenuItem.item as UIButton if you know it's a button?
            let width = UISlider(frame:CGRectMake(10, self.navigationController!.navigationBar.frame.height + 60, 230, 50))
            width.minimumValue = 0
            width.maximumValue = 100
            width.continuous = true
            width.backgroundColor = UIColor.darkGrayColor()
            width.value = 50
            width.addTarget(self, action: "widthManipulator:", forControlEvents: .ValueChanged)
            width.layer.shadowOffset = CGSize(width: 0, height: 2)
            width.layer.shadowOpacity = 0.7
            width.layer.shadowRadius = 2
            menuView.addSubview(width)
            
            // TODO: Look up generic storage and type checking
            let opacity = UISlider(frame:CGRectMake(10, self.navigationController!.navigationBar.frame.height + 120, 230, 50))
            opacity.minimumValue = 0
            opacity.maximumValue = 1
            opacity.continuous = true
            opacity.backgroundColor = UIColor.darkGrayColor()
            opacity.value = 50
            opacity.addTarget(self, action: "opacityManipulator:", forControlEvents: .ValueChanged)
            opacity.layer.shadowOffset = CGSize(width: 0, height: 2)
            opacity.layer.shadowOpacity = 0.7
            opacity.layer.shadowRadius = 2
            menuView.addSubview(opacity)
            
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
            if show.hidden {
                if let menuView = self.view.viewWithTag(100) {
                    // Nothing happens if we swipe and the menu is open
                }
                else {
                    drawMenu()
                }
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
    }
    
    @IBAction func new(sender: UIButton) {
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        sketchingView.newDrawing()
        //###
        sketchingView.redo()
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

