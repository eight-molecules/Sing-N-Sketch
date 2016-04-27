import UIKit


extension CALayer {
    
    func colorOfPoint(point: CGPoint) -> CGColorRef {
        var pixel: [CUnsignedChar] = [0,0,0,0]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let context = CGBitmapContextCreate(&pixel, 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)
        
        CGContextTranslateCTM(context, -point.x, -point.y)
        
        self.renderInContext(context!)
        
        let red:CGFloat = CGFloat(pixel[0])/255.0
        let green:CGFloat = CGFloat(pixel[1])/255.0
        let blue:CGFloat = CGFloat(pixel[2])/255.0
        let alpha:CGFloat = CGFloat(pixel[3])/255.0
        
        let color = UIColor(red:red, green: green, blue:blue, alpha:alpha)
        
        return color.CGColor
    }
    
}

class ColorMapView: UIImageView {
    var color: UIColor! = UIColor.blackColor()
    var gradientColor: UIColor! = UIColor.blackColor()
    
}

class ViewController: UIViewController {
    @IBOutlet weak var sketchingView: SketchingView!
    @IBOutlet weak var toolbarView: UIStackView!
    @IBOutlet weak var paletteStackView: UIStackView!
    @IBOutlet weak var colormapView: ColorMapView!
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var show: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var new: UIButton!
    @IBOutlet weak var add: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bounds = UIScreen.mainScreen().bounds
        self.view.frame = self.view.bounds
        self.sketchingView.autoresizingMask = .None
    }
    
    override func viewDidAppear(animated: Bool) {
        debugPrint("Started Audio")
        sketchingView.audio.update()
        
        indicator.layer.cornerRadius = indicator.frame.width / 2
        colormapView.layer.cornerRadius = 2
        colormapView.layer.borderColor = UIColor.blackColor().CGColor
        colormapView.layer.borderWidth = 1
        colormapView.clipsToBounds = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        show.addGestureRecognizer(longPress)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if colormapView.bounds.contains((touches.first?.locationInView(colormapView))!) {
            colormapView.color = UIColor(CGColor: colormapView.layer.colorOfPoint((touches.first?.locationInView(colormapView))!))
            indicator.backgroundColor = colormapView.color
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if colormapView.bounds.contains((touches.first?.locationInView(colormapView))!) {
            colormapView.color = UIColor(CGColor: colormapView.layer.colorOfPoint((touches.first?.locationInView(colormapView))!))
            indicator.backgroundColor = colormapView.color
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if colormapView.bounds.contains((touches.first?.locationInView(colormapView))!) {
            colormapView.color = UIColor(CGColor: colormapView.layer.colorOfPoint((touches.first?.locationInView(colormapView))!))
            indicator.backgroundColor = colormapView.color
        }
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
        var height: CGFloat = 50 + 200
        if heightConstant.constant > 50 {
            height = -1 * height
        }
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(1, animations: {
            self.heightConstant.constant += height
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func addMapping(sender: UIButton) {
        debugPrint("Adding Mapping")
        sketchingView.palette.addColor(sketchingView.audio.frequency.average, color: colormapView.color)
    }
    
    
    @IBAction func deleteMapping(sender: UIButton) {
        debugPrint("Deleting Mapping")
        //sketchingView.palette.deleteColor(sender.frequency)
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
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(1, animations: {
            self.heightConstant.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func show(sender: UIButton) {
        show.hidden = true
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(1, animations: {
        self.heightConstant.constant = 50
        self.view.layoutIfNeeded()
        })
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

