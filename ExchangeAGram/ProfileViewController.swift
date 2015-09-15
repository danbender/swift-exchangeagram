import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {
    @IBOutlet weak var profileImageview: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fbLoginView: FBLoginView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        profileImageview.hidden = false
        nameLabel.hidden = false
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        self.profileImageview.hidden = true
        self.nameLabel.hidden = true
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        
    }
 }
