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
        closeMenu()
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
    
    func drawMenu(sender: UIButton) {
        if menuView == nil {
            let menuView = MenuView(frame: CGRect(x: -250, y: 0, width: 250, height: self.view.frame.height))
            self.view.addSubview(menuView)
            
            menuView.open()
        }
    }
    
    func drawMenu() {
            
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
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = menuView.bounds
            menuView.addSubview(blurEffectView)
            
            if show.hidden == false {
                let title = UILabel(frame: CGRectMake(10, 0, 230, 40))
                title.text = navTitle
                title.backgroundColor = UIColor.clearColor()
                title.textAlignment = NSTextAlignment.Center
                title.textColor = UIColor.whiteColor()
                menuView.addSubview(title)
                
            }
            let offset = (x: CGFloat(0), y: CGFloat(0))
        
            let save   = UIButton() as UIButton
            save.frame = CGRectMake(10, 60, 110, 40)
            save.backgroundColor = UIColor(white: 0.1, alpha: 0)
            save.setTitle("Save", forState: UIControlState.Normal)
            save.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
            save.layer.shadowOffset = CGSize(width: 0, height: 1)
            save.layer.shadowOpacity = 0.7
            save.layer.shadowRadius = 2
            menuView.addSubview(save)
        
        
            let new   = UIButton() as UIButton
            new.frame = CGRectMake(130, 60, 110, 40)
            new.backgroundColor = UIColor(white: 0.1, alpha: 0)
            new.setTitle("New", forState: UIControlState.Normal)
            new.addTarget(self, action: "new:", forControlEvents: UIControlEvents.TouchUpInside)
            new.layer.shadowOffset = CGSize(width: 0, height: 1)
            new.layer.shadowOpacity = 0.7
            new.layer.shadowRadius = 2
            menuView.addSubview(new)
            
            let undo   = UIButton() as UIButton
            undo.frame = CGRectMake(10, 110, 110, 40)
            undo.backgroundColor = UIColor(white: 0.1, alpha: 0)
            undo.setTitle("Undo", forState: UIControlState.Normal)
            undo.addTarget(self, action: "undo:", forControlEvents: UIControlEvents.TouchUpInside)
            undo.layer.shadowOffset = CGSize(width: 0, height: 1)
            undo.layer.shadowOpacity = 0.7
            undo.layer.shadowRadius = 2
            menuView.addSubview(undo)
            
            let redo   = UIButton() as UIButton
            redo.frame = CGRectMake(130, 110, 110, 40)
            redo.backgroundColor = UIColor(white: 0.1, alpha: 0)
            redo.setTitle("Redo", forState: UIControlState.Normal)
            redo.addTarget(self, action: "redo:", forControlEvents: UIControlEvents.TouchUpInside)
            redo.layer.shadowOffset = CGSize(width: 0, height: 1)
            redo.layer.shadowOpacity = 0.7
            redo.layer.shadowRadius = 2
            menuView.addSubview(redo)
            
            let openPaletteEditor   = UIButton() as UIButton
            openPaletteEditor.frame = CGRectMake(10, 160 + offset.y, 230, 40)
            openPaletteEditor.backgroundColor = UIColor(white: 0.1, alpha: 0)
            openPaletteEditor.setTitle("Palette Editor", forState: UIControlState.Normal)
            openPaletteEditor.addTarget(self, action: "drawPaletteEditor:", forControlEvents: UIControlEvents.TouchUpInside)
            openPaletteEditor.layer.shadowOffset = CGSize(width: 0, height: 1)
            openPaletteEditor.layer.shadowOpacity = 0.7
            openPaletteEditor.layer.shadowRadius = 2
            menuView.addSubview(openPaletteEditor)
            
            let menuSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                action: "closeMenu")
            menuSwipeGestureRecognizer.direction = .Left
            menuView.addGestureRecognizer(menuSwipeGestureRecognizer)
            
            self.view.addSubview(menuView)
            self.view.bringSubviewToFront(toolbarView)
            
            UIView.animateWithDuration(0.7, animations: {
                var menuFrame = menuView.frame
                menuFrame.origin.x += menuFrame.size.width
                menuView.frame = menuFrame
                }
            )
        
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
        if (self.view.viewWithTag(100) != nil) {
            closeMenu()
        }
        else {
            drawMenu()
        }
    }
    
    func swipeMenu(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Ended {
            if self.view.viewWithTag(100) == nil {
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

