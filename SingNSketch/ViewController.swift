import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sketchingView: SketchingView!
    @IBOutlet weak var canvasView: UIImageView!
    
    @IBOutlet weak var hide: UIBarButtonItem!
    @IBOutlet weak var show: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var new: UIButton!
    @IBOutlet weak var navBarLabel: UINavigationItem!
    
    var navTitle: String = "Sing N' Sketch"
    
    // Outlet used in storyboard
    @IBOutlet var scrollView: UIScrollView?;
    
    var audio: AudioInterface = AudioInterface()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sketchingView.frame = view.bounds
        sketchingView.autoresizingMask = view.autoresizingMask
    }
    
    override func viewDidAppear(animated: Bool) {
        sketchingView.audio.start()
        sketchingView.audio.update()
        
        var hideButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Hide", style: UIBarButtonItemStyle.Plain, target: self, action: "hide:")
        self.title = navTitle
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
    }
    
    @IBAction func show(sender: UIButton) {
        navigationController!.navigationBarHidden = false
        show.hidden = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        show.addGestureRecognizer(longPress)
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
    
    @IBAction func showMenuView(sender: UIBarButtonItem) {
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        } else {
            var menuView = MenuView(frame: CGRectMake(0, 30, 250, 1000))
            menuView.backgroundColor = UIColor.grayColor()
            menuView.alpha = 1
            menuView.tag = 100
            menuView.userInteractionEnabled = true
            menuView.layer.shadowOffset = CGSize(width: 3, height: 0)
            menuView.layer.shadowOpacity = 0.7
            menuView.layer.shadowRadius = 2
            self.view.addSubview(menuView)
        
            let save   = UIButton() as UIButton
            save.frame = CGRectMake(10, 10, 110, 50)
            save.backgroundColor = UIColor.darkGrayColor()
            save.setTitle("Save", forState: UIControlState.Normal)
            save.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
            save.layer.shadowOffset = CGSize(width: 0, height: 2)
            save.layer.shadowOpacity = 0.7
            save.layer.shadowRadius = 2
            menuView.addSubview(save)
            
            let new   = UIButton() as UIButton
            new.frame = CGRectMake(130, 10, 110, 50)
            new.backgroundColor = UIColor.darkGrayColor()
            new.setTitle("Clear", forState: UIControlState.Normal)
            new.addTarget(self, action: "new:", forControlEvents: UIControlEvents.TouchUpInside)
            new.layer.shadowOffset = CGSize(width: 0, height: 2)
            new.layer.shadowOpacity = 0.7
            new.layer.shadowRadius = 2
            menuView.addSubview(new)
            
            var width = UISlider(frame:CGRectMake(10, 70, 230, 50))
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
           
        }
    }
    
    @IBAction func new(sender: UIButton) {
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        sketchingView.newDrawing()
    }
    
    // Interface slider actions
    @IBAction func opacityManipulator(sender: UISlider) {
        sketchingView.brush.opacity = CGFloat(sender.value)
    }
    
    @IBAction func widthManipulator(sender: UISlider) {
        sketchingView.brush.width = CGFloat(sender.value)
    }

}

