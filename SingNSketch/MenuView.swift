import Foundation
import UIKit


class MenuView : UIView {
    var image = UIImage()
    
    
    var blurEffect = UIBlurEffect()
    var blurEffectView = UIVisualEffectView()
    
    let width = UIView(frame: CGRectMake(10, 40, 230, 40))
    let widthSlider = UISlider(frame: CGRectMake(80, 0, 140, 40))
    let widthLabel = UILabel(frame: CGRectMake(10, 0, 60, 40))
    
    
    let opacity = UIView(frame: CGRectMake(10, 90, 230, 40))
    let opacitySlider = UISlider(frame: CGRectMake(80, 0, 140, 40))
    let opacityLabel = UILabel(frame: CGRectMake(10, 0, 60, 40))
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        self.backgroundColor = UIColor.clearColor()
        self.alpha = 1
        self.tag = 100
        self.userInteractionEnabled = true
        self.layer.shadowOffset = CGSize(width: 3, height: -2)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 2
        
        blurEffectView.frame = self.bounds
        self.addSubview(self.blurEffectView)
    }
    
    func drawMenu() {
        // This is bad. All of this is bad, and will be updated to be better.
        
        
        
        // Can you just call MenuItem.item as UIButton if you know it's a button?
        
        
        width.backgroundColor = UIColor(white: 0.1, alpha: 0)
        width.layer.shadowOffset = CGSize(width: 0, height: 1)
        width.layer.shadowOpacity = 0.7
        width.layer.shadowRadius = 2
        
        widthLabel.text = "Width"
        widthLabel.textColor = UIColor.whiteColor()
        widthLabel.textAlignment = NSTextAlignment.Center
        
        widthSlider.minimumValue = 1
        widthSlider.maximumValue = 50
        widthSlider.continuous = true
        widthSlider.value = Float(50)
        widthSlider.addTarget(self, action: "widthManipulator:", forControlEvents: .ValueChanged)
        
        width.addSubview(widthSlider)
        width.addSubview(widthLabel)
        self.addSubview(width)
        
        // TODO: Look up generic storage and type checking
        
        opacity.backgroundColor = UIColor(white: 0.1, alpha: 0)
        opacity.layer.shadowOffset = CGSize(width: 0, height: 1)
        opacity.layer.shadowOpacity = 0.7
        opacity.layer.shadowRadius = 2
        
        opacityLabel.text = "Opacity"
        opacityLabel.textColor = UIColor.whiteColor()
        opacityLabel.textAlignment = NSTextAlignment.Center
        
        opacitySlider.minimumValue = 0
        opacitySlider.maximumValue = 1
        opacitySlider.continuous = true
        opacitySlider.value = Float(1)
        opacitySlider.addTarget(self, action: "opacityManipulator:", forControlEvents: .ValueChanged)
        
        opacity.addSubview(opacitySlider)
        opacity.addSubview(opacityLabel)
        self.addSubview(opacity)
        
        // Like look at all this. I'm creating a MenuItem with an embedded derivative of UIView
        let save   = UIButton() as UIButton
        save.frame = CGRectMake(10, 140, 110, 40)
        save.backgroundColor = UIColor(white: 0.1, alpha: 0)
        save.setTitle("Save", forState: UIControlState.Normal)
        save.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
        save.layer.shadowOffset = CGSize(width: 0, height: 1)
        save.layer.shadowOpacity = 0.7
        save.layer.shadowRadius = 2
        self.addSubview(save)
        
        // This could totally be embedded in a class. MenuItem.item -> UIView?
        let new   = UIButton() as UIButton
        new.frame = CGRectMake(130, 140, 110, 40)
        new.backgroundColor = UIColor(white: 0.1, alpha: 0)
        new.setTitle("New", forState: UIControlState.Normal)
        new.addTarget(self, action: "new:", forControlEvents: UIControlEvents.TouchUpInside)
        new.layer.shadowOffset = CGSize(width: 0, height: 1)
        new.layer.shadowOpacity = 0.7
        new.layer.shadowRadius = 2
        self.addSubview(new)
        
        let undo   = UIButton() as UIButton
        undo.frame = CGRectMake(10, 190, 110, 40)
        undo.backgroundColor = UIColor(white: 0.1, alpha: 0)
        undo.setTitle("Undo", forState: UIControlState.Normal)
        undo.addTarget(self, action: "undo:", forControlEvents: UIControlEvents.TouchUpInside)
        undo.layer.shadowOffset = CGSize(width: 0, height: 1)
        undo.layer.shadowOpacity = 0.7
        undo.layer.shadowRadius = 2
        self.addSubview(undo)
        
        let redo   = UIButton() as UIButton
        redo.frame = CGRectMake(130, 190, 110, 40)
        redo.backgroundColor = UIColor(white: 0.1, alpha: 0)
        redo.setTitle("Redo", forState: UIControlState.Normal)
        redo.addTarget(self, action: "redo:", forControlEvents: UIControlEvents.TouchUpInside)
        redo.layer.shadowOffset = CGSize(width: 0, height: 1)
        redo.layer.shadowOpacity = 0.7
        redo.layer.shadowRadius = 2
        self.addSubview(redo)
        
        let openPaletteEditor   = UIButton() as UIButton
        openPaletteEditor.frame = CGRectMake(10, 240, 230, 40)
        openPaletteEditor.backgroundColor = UIColor(white: 0.1, alpha: 0)
        openPaletteEditor.setTitle("Palette Editor", forState: UIControlState.Normal)
        openPaletteEditor.addTarget(self, action: "drawPaletteEditor", forControlEvents: UIControlEvents.TouchUpInside)
        openPaletteEditor.layer.shadowOffset = CGSize(width: 0, height: 1)
        openPaletteEditor.layer.shadowOpacity = 0.7
        openPaletteEditor.layer.shadowRadius = 2
        self.addSubview(openPaletteEditor)
        
        let menuSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
            action: "closeMenu")
        menuSwipeGestureRecognizer.direction = .Left
        self.addGestureRecognizer(menuSwipeGestureRecognizer)
        
        UIView.animateWithDuration(0.7, animations: {
            var menuFrame = self.frame
            menuFrame.origin.x += menuFrame.size.width
            
            self.frame = menuFrame
            }
        )
    }
    
}

