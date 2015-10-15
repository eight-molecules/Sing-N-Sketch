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
    
    @IBOutlet weak var wholeView: UIImageView!
    
    @IBOutlet weak var hide: UIButton!
    @IBOutlet weak var show: UIButton!
    
    @IBOutlet weak var navBarLabel: UINavigationItem!
    
    var audio: AudioInterface = AudioInterface()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    
    @IBAction func showMenu(sender: UIButton) {
        self.performSegueWithIdentifier("menuSegue", sender: self)
    }
    
    @IBAction func save(sender: UIButton) {
        wholeView.image = sketchingView.drawImage
        UIImageWriteToSavedPhotosAlbum(wholeView.image, self, "image:didFinishSavingWithError:contextInfo:", nil)
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
    }
}
