import Foundation
import UIKit

class PaletteButton: UIButton {
    var frequency: Float! = 0
    var color: UIColor! = UIColor.blackColor()
}

class MenuView : UIView {
    var image = UIImage()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}