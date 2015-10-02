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
    
    var audio: AudioInterface = AudioInterface()
    
    // Basic pitch mappings. Do not re-use, we have a framework for this.
    let noteFrequencies = [16.35,17.32,18.35,19.45,20.6,21.83,23.12,24.5,25.96,27.5,29.14,30.87]
    let noteNamesWithSharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
    let noteNamesWithFlats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]
    
    
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
}
