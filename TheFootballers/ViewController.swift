//
//  ViewController.swift
//  TheFootballers
//
//  Created by Ran Pulvernis on 27/01/2017.
//  Copyright © 2017 RanPulvernis. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate var refSelection: FIRDatabaseReference!
    
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    
    // in Firebase: selection is array of Dictionary teams -> ["a-Team", "wowww-Team"]
    //Team is array with 4 Dictionary position -> ["Attack", "Midfielder", "Defence", "GoalKeeper"]
    //Position is array of Dictionary players Number and their Names ("1":"Ran" , "2":"David" and etc)
    // groupSelection: [Dictionary<group, Dictionary<team, Dictionary<position, Dictionary<player Number, player Name>>>>]
    fileprivate var groupSelection: [Dictionary<String, Any>]!
    // teamSelection: [Dictionary<team, Dictionary<position, Dictionary<player Number, player Name>>>]
    fileprivate var teamSelection: [Dictionary<String, Any>]!
    // positionSelection: [Dictionary<position, Dictionary<player number, player name>>]
    fileprivate var positionSelection: [Dictionary<String, Any>]!
    // playerSelection: Dictionary<player number, player name>
    fileprivate var playerSelection: Dictionary<String, String>!
    
    fileprivate var childrenPathStrArr:[String]?
    fileprivate var teamsStrArr = [String]()
    fileprivate var positionStrArr = [String]()
    
    fileprivate var numberAndNamePlayersDict: [Dictionary<String, String>]!
    
    fileprivate var heightPositionForLabel:CGFloat = 5
    
    var myGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        GIDSignIn.sharedInstance().uiDelegate = self
        googleLoginButton.style = .wide
        let googleUser = GIDSignIn.sharedInstance().currentUser
        if(googleUser == nil){
            print("out of google")
        }
        // add image view UIScreen.main.bounds
        let imageName = "soccer_1.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: UIScreen.main.bounds.width/10, y: UIScreen.main.bounds.height*39/80, width: UIScreen.main.bounds.width*4/5, height: UIScreen.main.bounds.height/2)
        view.addSubview(imageView)
        
        
        // ***TODO: Show teams with all players name and position***
        // MOVE THE CODE TO GroupSelectionVC
        refSelection = ref.child("Groups").child("r").child("selection")
        
        //teamsStrArr = getAllChildrenToArr()
    }
    
    @IBAction func btnGoogleSignIn(_ sender: GIDSignInButton) {
        
    }

    @IBAction func btnSignUp(_ sender: UIButton) {
        
    }

    @IBAction func btnSignIn(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Insert Mail and Password", message: "press Confirm for SignIn or Cancel to get out", preferredStyle: .alert)
        //handle confirm button
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            alert -> Void in
            //get the textfields to strings for check
            let email = alertController.textFields![0] as UITextField
            let password = alertController.textFields![1] as UITextField
            let emailStr = email.text!
            let passwordStr = password.text!
            
            print("Email: \(emailStr), Password: \(passwordStr)")
            if(emailStr.isEmpty || passwordStr.isEmpty){
                self.view.makeToast("At least one field is empty", duration: 3.0, position: .bottom)
            }else{
                FIRAuth.auth()?.signIn(withEmail: emailStr, password: passwordStr) { (user, error) in
                    // ...
                    
                    if error != nil {
                        
                        if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                            
                            switch errCode {
                            case .errorCodeInvalidEmail:
                                 self.view.makeToast("Invalid Email", duration: 3.0, position: .bottom)
                            case .errorCodeWrongPassword:
                                 self.view.makeToast("Wrong Password", duration: 3.0, position: .bottom)
                            default:
                                print(error!)
                                self.view.makeToast("SignIn User Error", duration: 3.0, position: .bottom)
                            }
                        }
                        
                    } else {
                        //print("Wellcome \(user!.email!)")
                        self.performSegue(withIdentifier: "toSignInToGroupViewController", sender: self)
                        
                    }
                }
            }
            
        })
        //handle cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        //add two textfields
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter mail"
            textField.keyboardType = .emailAddress
        }
        
        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Enter password"
            textField.isSecureTextEntry = true
        }
        
        //add the action buttons
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        //show the alert
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func handleLogin(){
        showHomeViewController()
    }
    
    func showHomeViewController(){
        let toHomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "AfterLoginVC") as! HomePageViewController
        self.navigationController?.pushViewController(toHomeViewController, animated: true)
    }
    
    func createUILabel(text:String, fontStyle:UIFontTextStyle, heightPosition: CGFloat) -> UILabel{
        // CGRectMake has been deprecated - and should be let, not var
        let label = UILabel(frame: CGRect(x: 100, y: 40, width: 200, height: 21))
        
        // you will probably want to set the font (remember to use Dynamic Type!)
        label.font = UIFont.preferredFont(forTextStyle: fontStyle)
        
        // and set the text color too - remember good contrast
        label.textColor = .black
        
        // may not be necessary (e.g., if the width & height match the superview)
        // if you do need to center, CGPointMake has been deprecated, so use this
        label.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height*heightPosition/20)
        
        label.backgroundColor = UIColor.cyan
        
        // this changed in Swift 3 (much better, no?)
        label.textAlignment = .center
        
        label.text = text
        
        return label
        
        //self.view.addSubview(label)
    }
    
    func getAllChildrenToDictionary() -> [String:Dictionary<String, Dictionary<String, String>>]{
        var teamsStrArr = [String]()
        var positionStrArr = [String]()
        var playerStrArr = [String:String]()
        
        var teamDict = [String:Dictionary<String, Dictionary<String, String>>]()
        var positionDict = [String:Dictionary<String, String>]()
        
        self.myGroup.enter()
        refSelection.observeSingleEvent(of: .value, with: { (snapshot) in
            // get into teams
            for team in snapshot.children {
                teamsStrArr.append((team as AnyObject).key) //a-Team, wowww-Team
                print("\((team as AnyObject).key!)")
                self.refSelection.child((team as AnyObject).key).observeSingleEvent(of: .value, with: { (snapshot) in
                    // get into positions
                    for position in snapshot.children {
                        positionStrArr.append((position as AnyObject).key) //Attack, Defence and etc
                        print("\((position as AnyObject).key!)")
                        self.refSelection.child((team as AnyObject).key).child((position as AnyObject).key).observeSingleEvent(of: .value, with: { (snapshot) in
                            // get into players
                            for player in snapshot.children {
                                playerStrArr[(player as AnyObject).key] = (player as AnyObject).value //1:name1, 2:name2
                                positionDict[(position as AnyObject).key] = playerStrArr
                                
                                //GET PALYER TO POSITION IN HIS TEAM
                                teamDict[(team as AnyObject).key!]?[(position as AnyObject).key!]?[(player as AnyObject).key] = (player as AnyObject).value
                                
                                print("\((player as AnyObject).key!):\(((player as AnyObject).value) as String)")
                            }
                        })
                    }
                })
            }
            self.myGroup.leave()
        })
        myGroup.notify(queue: DispatchQueue.main, execute: {
            print("Finished all requests.")
            
        })
        return teamDict
    }
    
    //overload method
    func getAllChildrenToArr(path:[String]) -> [String]{
        var strArr: Array<String>!
        var refForChildren: FIRDatabaseReference!
        switch path.count {
        case 1:
            refForChildren = refSelection.child(path[0])
            break
        case 2:
            refForChildren = refSelection.child(path[0]).child(path[1])
            break
        default:
            print("path Array can contains Max of two Strings")
            break
        }
        self.myGroup.enter()
        refForChildren.observeSingleEvent(of: .value, with: { (snapshot) in
            // get into teams
            for child in snapshot.children {
                strArr.append((child as AnyObject).key) //a-Team, wowww-Team
            }
            self.myGroup.leave()
            
        })
        
        return strArr as [String]
        
    }
    
}

