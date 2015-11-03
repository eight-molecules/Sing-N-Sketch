import UIKit

@objc
protocol ViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}

class ViewController: UIViewController {
    
    var delegate: ViewControllerDelegate?
    @IBOutlet weak var sketchingView: SketchingView!
    
    @IBOutlet weak var canvasView: UIImageView!
    
    @IBOutlet weak var hide: UIButton!
    @IBOutlet weak var show: UIButton!
    
    @IBOutlet weak var navBarLabel: UINavigationItem!
    
    // Outlet used in storyboard
    @IBOutlet var scrollView: UIScrollView?;
    
    var audio: AudioInterface = AudioInterface()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scrollView?.panGestureRecognizer.minimumNumberOfTouches = 2
        sketchingView.frame = view.bounds
        sketchingView.autoresizingMask = view.autoresizingMask
        
        // 1) Create the three views used in the swipe container view
        var AVc :AViewController =  AViewController(nibName: "AViewController", bundle: nil);
        var BVc :MenuViewController = MenuViewController(nibName: "MenuViewController", bundle: nil)
        
        
        // 2) Add in each view to the container view hierarchy
        //    Add them in opposite order since the view hieracrhy is a stack
        
        
        self.addChildViewController(BVc);
        self.scrollView!.addSubview(BVc.view);
        BVc.didMoveToParentViewController(self);
        
        self.addChildViewController(AVc);
        self.scrollView!.addSubview(AVc.view);
        AVc.didMoveToParentViewController(self);
        
        
        // 3) Set up the frames of the view controllers to align
        //    with eachother inside the container view
        var adminFrame :CGRect = AVc.view.frame;
        adminFrame.origin.x = adminFrame.width;
        BVc.view.frame = adminFrame;
        
        var BFrame :CGRect = BVc.view.frame;
        BFrame.origin.x = 2*BFrame.width;
        AVc.view.frame = BFrame;
        
        
        // 4) Finally set the size of the scroll view that contains the frames
        var scrollWidth: CGFloat  = 3 * self.view.frame.width
        var scrollHeight: CGFloat  = self.view.frame.size.height
        self.scrollView!.contentSize = CGSizeMake(scrollWidth, scrollHeight);
        
        //shadows
        scrollView!.layer.shadowColor = UIColor.grayColor().CGColor;
        scrollView!.layer.shadowOpacity = 0.5;

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
    
    
    @IBAction func showMenu(sender: UIButton) {
        self.performSegueWithIdentifier("menuSegue", sender: self)
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
}

