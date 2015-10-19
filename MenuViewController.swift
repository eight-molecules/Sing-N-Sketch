import UIKit
class MenuViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Put this setup code in the viewDidLoad method.
        self.view.backgroundColor = UIColor.grayColor()
        
    }
    
    @IBAction func returnFromMenu(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
}