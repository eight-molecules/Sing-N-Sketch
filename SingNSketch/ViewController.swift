import UIKit

class ToolbarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var tools: UICollectionView!
    @IBOutlet var items: [UIView]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Number of cells to generate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items!.count
    }
    
    // Cell generation function
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = tools.dequeueReusableCellWithReuseIdentifier("tool", forIndexPath: indexPath) as! ToolbarViewCell
        let item = items![indexPath.item]
        cell.view = item
        cell.addSubview(cell.view)
        cell.sizeToFit()
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    //Use for size
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = items[indexPath.item].frame.size
        size.width = size.width + 10
        size.height = size.height + 10
        return size
    }
    //Use for interspacing
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
}

class ToolbarViewCell: UICollectionViewCell {
    @IBOutlet weak var view: UIView!
}

class ViewController: UIViewController {
    @IBOutlet weak var sketchingView: SketchingView! = nil
    @IBOutlet weak var canvasView: UIImageView! = nil
    @IBOutlet weak var menuView: MenuView! = nil
    @IBOutlet weak var toolbarView: ToolbarView!
    @IBOutlet weak var paletteEditor: PaletteEditorView! = nil
    
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
        
        self.toolbarView.bounds.origin = self.view.bounds.origin
        self.toolbarView.bounds.size.width = self.view.frame.size.width
        self.toolbarView.tools.frame.size.width = self.view.frame.width
        
        let menu = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        menu.setTitle("Menu", forState: .Normal)
        menu.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        menu.addTarget(self, action: "showMenuView:", forControlEvents: .TouchUpInside)
        
        let hide = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        hide.setTitle("Hide", forState: .Normal)
        hide.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        hide.addTarget(self, action: "hide:", forControlEvents: .TouchUpInside)
        
        let widthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        widthLabel.text = "Width"
        widthLabel.textColor = UIColor.whiteColor()
        
        let widthSlider = UISlider(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        widthSlider.minimumValue = 1
        widthSlider.maximumValue = 50
        widthSlider.addTarget(self, action: "widthManipulator:", forControlEvents: .TouchUpInside)
        widthSlider.continuous = true
        widthSlider.value = Float(sketchingView.brush.width)
        
        let redo = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        redo.setTitle("Redo", forState: .Normal)
        redo.addTarget(self, action: "redo:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let undo = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        undo.setTitle("Undo", forState: .Normal)
        undo.addTarget(self, action: "undo:", forControlEvents: UIControlEvents.TouchUpInside)
        
        items.append(menu)
        items.append(hide)
        items.append(widthLabel)
        items.append(widthSlider)
        items.append(redo)
        items.append(undo)
        self.toolbarView.items = self.items
        
        sketchingView.frame = view.bounds
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "swipeMenu:")
        screenEdgeRecognizer.edges = .Left
        sketchingView.addGestureRecognizer(screenEdgeRecognizer)
        
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
    
    // Hide navigation
    @IBAction func hide(sender: UIButton) {
        show.hidden = false
        self.toolbarView.hidden = true
    }
    
    @IBAction func show(sender: UIButton) {
        show.hidden = true
        self.toolbarView.hidden = false
    }
    
    @IBAction func drawPaletteEditor(sender: UIButton) {
        if paletteEditor == nil {
            let paletteEditor = PaletteEditorView(frame: CGRect(x: -250, y: 0, width: 250, height: self.view.frame.height), palette: sketchingView.palette, audio: sketchingView.audio)
            self.view.addSubview(paletteEditor)
            
            paletteEditor.open()
        }
        else {
            debugPrint("Palette Editor already open!")
        }
    }
    
    // Save function for the current canvas
    @IBAction func save(sender: UIButton) {
        if let img = canvasView.image {
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
    
    
    
    @IBAction func showMenuView(sender: UIButton) {
        var height: CGFloat = 50
        if self.toolbarView.frame.height > 50 {
            height = -50
        }
        UIView.animateWithDuration(0.7, animations: {
            var frame = self.toolbarView.frame
            frame.size.height += height
            self.toolbarView.frame = frame
            })
    }
    
    
    
    @IBAction func new(sender: UIButton) {
        sketchingView.newDrawing()
    }
    
    // Interface slider actions
    @IBAction func opacityManipulator(sender: UISlider) {
        sketchingView.brush.opacity = CGFloat(sender.value)
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

