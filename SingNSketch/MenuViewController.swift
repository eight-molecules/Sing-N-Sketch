import UIKit
class MenuViewController: UITableViewController, UITableViewDelegate {
    @IBOutlet var menuTableView: UITableView! {
        didSet{
            menuTableView.delegate = self
            menuTableView.bounces = false
        }
    }
    
    struct Notifications {
        static let MainSelected = "MainSelected"
        static let RedSelected = "RedSelected"
        static let GreenSelected = "GreenSelected"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = indexPath.item
        let center = NSNotificationCenter.defaultCenter()
        
        switch item {
        case 0:
            center.postNotification(NSNotification(name: Notifications.MainSelected, object: self))
        case 1:
            center.postNotification(NSNotification(name: Notifications.RedSelected, object: self))
        case 2:
            center.postNotification(NSNotification(name: Notifications.GreenSelected, object: self))
        default:
            println("Unrecognized menu index")
            return
        }
    }
}