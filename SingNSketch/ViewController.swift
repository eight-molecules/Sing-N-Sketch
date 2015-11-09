import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sketchingView: SketchingView!
    @IBOutlet weak var canvasView: UIImageView!
    
    @IBOutlet weak var hide: UIBarButtonItem!
    @IBOutlet weak var show: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var new: UIButton!
    @IBOutlet weak var navBarLabel: UINavigationItem!
    
    var audio: AudioInterface = AudioInterface()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sketchingView.frame = view.bounds
        sketchingView.autoresizingMask = view.autoresizingMask
    }
    
    override func viewDidAppear(animated: Bool) {
        sketchingView.audio.start()
        sketchingView.audio.update()
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
    
    @IBAction func hide(sender: UIButton) {
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
            var menuView = MenuView(frame: CGRectMake(0, 0, 250, 1000))
            menuView.backgroundColor = UIColor.blackColor()
            menuView.alpha = 1
            menuView.tag = 100
            menuView.userInteractionEnabled = true
            
            self.view.addSubview(menuView)
        
            let save   = UIButton() as UIButton
            save.frame = CGRectMake(10, 75, 110, 110)
            save.backgroundColor = UIColor.darkGrayColor()
            save.setTitle("Save", forState: UIControlState.Normal)
            save.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
            menuView.addSubview(save)
            
            let new   = UIButton() as UIButton
            new.frame = CGRectMake(130, 75, 110, 110)
            new.backgroundColor = UIColor.darkGrayColor()
            new.setTitle("Clear", forState: UIControlState.Normal)
            new.addTarget(self, action: "new:", forControlEvents: UIControlEvents.TouchUpInside)
            menuView.addSubview(new)
        }
    }
    
    @IBAction func new(sender: UIButton) {
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        sketchingView.newDrawing()
    }
}

