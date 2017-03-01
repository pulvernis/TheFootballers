import UIKit
import Firebase

class HomePageViewController: UITableViewController {
    
    fileprivate let prefs = UserDefaults.standard;
    fileprivate var allPlayersDivideByPosition:[String:[String]] = [:];
    fileprivate var allPlayersNames:[String] = [];
    fileprivate var position:[String]=[]; //Attack, MidFielder, Defence, GoalKeeper -> initialize from viewDidLoad
    
    fileprivate var groupNameStr:String?
    
    @IBOutlet weak var uploadPlayersCell: UITableViewCell!
    @IBOutlet weak var viewLastSelection: UITableViewCell!
    
    fileprivate let ref = FIRDatabase.database().reference()
    fileprivate var refGroup:FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refGroup = ref.child("Groups").child(groupNameStr!)
        
        if(groupNameStr != nil){
            print("\(groupNameStr!) String has moved to HomePageVC")
        }else{
            print("group name doesn't pass to this VC")
        }
        
        self.position = ["Attack", "Midfielder", "Defence", "Goalkeeper"];
        if (prefs.value(forKey: "allPlayersDivideByPosition") != nil){
            uploadPlayersCell.isHidden = false;
        }
        
        self.view.addBackground("fb.png") // <- from ExtensionUIView
    }
    
    func setMsg(groupName:String){
        self.groupNameStr = groupName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (prefs.value(forKey: "allPlayersDivideByPosition") != nil){
            self.allPlayersDivideByPosition = prefs.value(forKey: "allPlayersDivideByPosition")! as! [String:[String]];
            self.allPlayersNames = prefs.value(forKey: "allPlayersNames")! as! [String]
        }else{
            uploadPlayersCell.isHidden = true;
            self.allPlayersDivideByPosition = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]];
        }
        
        refGroup?.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("selection"){
                self.viewLastSelection.isHidden = false
                print("selection exist in firebase -> show view last selection row")
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddAllPlayersVCWithUpload"{
            let nextScrn = segue.destination as! AddAllPlayersViewController;
            nextScrn.setMsg(self.allPlayersDivideByPosition, allPlayersNames: self.allPlayersNames, groupName: self.groupNameStr!);
        }
        
        if segue.identifier == "toAddAllPlayers"{
            let nextScrn = segue.destination as! AddAllPlayersViewController;
            nextScrn.setMsg(groupName: self.groupNameStr!);
        }
        
        if segue.identifier == "toSignInPage"{
            let firebaseAuth = FIRAuth.auth()
            let googleAuth = GIDSignIn.sharedInstance()
            if((firebaseAuth) != nil){
                do {
                    try firebaseAuth?.signOut()
                    print("user disconnect firebase from homeVC")
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                if(googleAuth?.currentUser != nil){
                    print("disconnect user: \(googleAuth?.currentUser)")
                    print("sign out google from homeVC")
                    googleAuth?.disconnect()
                }
            }
            _ = segue.destination as! ViewController;
        }
        
        if segue.identifier == "toViewSelection"{
            let nextScrn = segue.destination as! GroupSelectionViewController;
            nextScrn.setMsg(groupName: groupNameStr!);
            
        }
    }
    
    
}
