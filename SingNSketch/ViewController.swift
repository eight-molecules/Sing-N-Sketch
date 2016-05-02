import UIKit

class SnapSlider: UISlider {
}

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

extension CAGradientLayer {
    
    func generateGradient(c: [CGColor], f: [Float]) -> CAGradientLayer {
        let gradientColors: [CGColor] = c
        let gradientLocations: [Float] = f
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        return gradientLayer
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
    @IBOutlet weak var mappingView: GradientView!
    @IBOutlet weak var mappingSlider: SnapSlider!
    @IBOutlet weak var freqRangeSlider: RangeSlider!
    
    var gradient: CALayer!
    
    @IBOutlet weak var show: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var new: UIButton!
    @IBOutlet weak var add: UIButton!
    
    var mappedFreq: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bounds = UIScreen.mainScreen().bounds
        self.view.frame = self.view.bounds
        self.sketchingView.autoresizingMask = .None
    }
    
    override func viewDidAppear(animated: Bool) {
        debugPrint("Started Audio")
        sketchingView.audio.update()
        
        mappingView.direction = GradientView.Direction.Horizontal
        updateMappingsGradient()
        
        colormapView.layer.cornerRadius = 2
        colormapView.layer.borderColor = UIColor.blackColor().CGColor
        colormapView.layer.borderWidth = 2
        colormapView.clipsToBounds = true
        
        indicator.layer.borderWidth = 1
        indicator.layer.borderColor = UIColor.blackColor().CGColor
        indicator.layer.cornerRadius = indicator.frame.height / 2
        
        heightConstant.constant = 50
        
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
        var height: CGFloat = 250
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
        
        sketchingView.audio.clearFrequency()
        if mappedFreq == nil {
        sketchingView.palette.addColor(sketchingView.audio.frequency.average, color: colormapView.color)
            mappedFreq = nil
        }
        else {
            sketchingView.palette.addColor(mappedFreq, color: colormapView.color)
        }
        updateMappingsGradient()
    }
    
    
    @IBAction func deleteMapping(sender: UIButton) {
        debugPrint("Deleting Mapping")
        // sketchingView.palette.deleteColor()
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
    
    @IBAction func clear(sender: UIButton) {
        sketchingView.palette = Palette()
        sketchingView.palette.addColor(sketchingView.minFreq, color: UIColor.blackColor())
        sketchingView.palette.addColor(sketchingView.maxFreq, color: UIColor.blackColor())
        
        updateMappingsGradient()
    }
    
    @IBAction func mappingSlider(sender: SnapSlider) {
        mappedFreq = Double(sender.value)
        indicator.backgroundColor = sketchingView.palette.getColor(Double(sender.value))
        mappingSlider.minimumTrackTintColor = indicator.backgroundColor
    }
    
    func updateMappingsGradient()  {
        
        let mappings = sketchingView.palette.getMappings()
        var colors: [UIColor] = []
        var locations: [CGFloat] = []
        var keys = mappings.keys.sort(>)
        keys.popLast()
        keys = keys.sort(<)
        keys.popLast()
    
        
        colors.append(UIColor.blackColor())
        locations.append(0)
        for f in keys {
            if f > 99 && f < 400 {
                let c = mappings[f] as UIColor!
                colors.append(c)
                
                let loc = (f - 99) / (400 -
                    99)
                locations.append(CGFloat(loc))
                
            }
        }
        colors.append(UIColor.blackColor())
        locations.append(1)
        
        mappingView.colors = colors
        mappingView.locations = locations
        
        mappingSlider.minimumValue = Float(keys.first!)
        mappingSlider.maximumValue = Float(keys.last!)
    }
}


