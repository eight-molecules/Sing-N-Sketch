import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var sketchingView: SketchingView! = nil
    @IBOutlet weak var canvasView: UIImageView! = nil
    @IBOutlet weak var menuView: MenuView! = nil
    @IBOutlet weak var toolbarView: UIView!
    
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    
    // TODO: These need to be consolidated with the 
    // menu code after the menu has been storyboarded.
    @IBOutlet weak var show: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var new: UIButton!
    var navTitle: String = "Sing N' Sketch"
    var items: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bounds = UIScreen.mainScreen().bounds
        self.view.frame = self.view.bounds
    }
    
    override func viewDidAppear(animated: Bool) {
        debugPrint("Started Audio")
        sketchingView.audio.update()
        
        self.toolbarView.frame.size.height = 50
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        show.addGestureRecognizer(longPress)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
        @IBAction func showMenuView(sender: UIButton) {
        var height: CGFloat = 35
        if self.toolbarView.frame.height > 50 {
            height = -1 * height
        }
        UIView.animateWithDuration(0.7, animations: {
            var frame = self.toolbarView.frame
            frame.size.height += height
            self.toolbarView.frame = frame
            })
    }
    
    // Save function for the current canvas
    @IBAction func save(sender: UIButton) {
        if let img = sketchingView.canvasView.image {
            UIImageWriteToSavedPhotosAlbum(img, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    // Alert image creation status on return
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        // Save was successful
        if error == nil {
            let ac = UIAlertController(title: "Saved to Photos", message: "Your image has been saved successfully!", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Error Saving to Photos", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    // Hide navigation
    @IBAction func hide(sender: UIButton) {
        show.hidden = false
        self.toolbarView.hidden = true
    }
    
    @IBAction func show(sender: UIButton) {
        show.hidden = true
        self.toolbarView.hidden = false
    }
    
    @IBAction func new(sender: UIButton) {
        sketchingView.newDrawing()
    }
    
    @IBAction func widthManipulator(sender: UISlider) {
        sketchingView.brush.width = CGFloat(sender.value)
    }
    
    @IBAction func redo(sender: UIButton) {
        sketchingView.redo()
    }
    
    @IBAction func undo(sender: UIButton) {
        sketchingView.undo()
    }
}

