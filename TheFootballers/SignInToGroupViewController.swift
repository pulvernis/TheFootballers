//
//  SignInToGroupViewController.swift
//  TheFootballers
//
//  Created by Ran Pulvernis on 02/02/2017.
//  Copyright © 2017 RanPulvernis. All rights reserved.
//

import UIKit
import Firebase

class SignInToGroupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblWellcomeUser: UILabel!
    
    @IBOutlet weak var txtGroupName: UITextField!
    @IBOutlet weak var txtGroupPass: UITextField!
    
    @IBOutlet weak var txtNewName: UITextField!
    @IBOutlet weak var txtPassForNewGroup: UITextField!
    @IBOutlet weak var txtConfirmPass: UITextField!
    
    @IBOutlet weak var txtGroupNameForViewSelection: UITextField!
    
    fileprivate var groupNameStr:String!
    fileprivate var groupPassStr:String!
    
    fileprivate var newNameStr:String!
    fileprivate var passForNewGroupStr:String!
    fileprivate var confirmPassStr:String!
    
    fileprivate var groupNameForViewSelectionStr:String!
    
    fileprivate var user:String = ""
    fileprivate var ref: FIRDatabaseReference!
    fileprivate var refGroup: FIRDatabaseReference!
    fileprivate var refSelection: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        //delegate TextFields for hide keyboard, when pressed 'return' in keyboard, by func textFieldShouldReturn
        txtGroupName.delegate = self
        txtGroupPass.delegate = self
        txtNewName.delegate = self
        txtPassForNewGroup.delegate = self
        txtConfirmPass.delegate = self
        txtGroupNameForViewSelection.delegate = self
        
        ref = FIRDatabase.database().reference()
        refGroup = ref.child("Groups")
        
        if(FIRAuth.auth() != nil){
            if(GIDSignIn.sharedInstance().currentUser != nil){
                user = (FIRAuth.auth()?.currentUser?.displayName)!
            }else{
                user = (FIRAuth.auth()?.currentUser?.email)!
            }
            print("Wellcome \(user)")
            lblWellcomeUser.text = "Wellcome \(user)"
            print(ref)
        }else{
            //TODO return to sign in page (ViewController)
            print("user is not connected")
        }

    }
    
    func setMsg(){
        
    }
    
    
    @IBAction func btnSignIn(_ sender: UIButton) {
        groupNameStr = txtGroupName.text!
        groupPassStr = txtGroupPass.text!
        
        if(groupNameStr.isEmpty || groupPassStr.isEmpty){
            self.view.makeToast("At least one field is empty", duration: 3.0, position: .center)
        }else{
            refGroup.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.hasChild(self.groupNameStr){
                    
                    self.refGroup.child(self.groupNameStr).child("Password").observeSingleEvent(of: .value, with: { (snapshot) in
                        if(snapshot.value as! String == self.groupPassStr){
                            self.performSegue(withIdentifier: "toHomePage", sender: self)
                            
                        }else{
                            self.view.makeToast("Password doesn't match to Group", duration: 3.0, position: .center)
                        }
                    })
                    
                    
                    
                }else{
                    self.view.makeToast("\(self.groupNameStr!) doesn't exist", duration: 3.0, position: .center)
                    print("\(self.groupNameStr!) doesn't exist")
                    
                }
                
                
            })

            
        }

        
    }
    
    @IBAction func btnSignUp(_ sender: UIButton) {
        newNameStr = txtNewName.text!
        passForNewGroupStr = txtPassForNewGroup.text!
        confirmPassStr = txtConfirmPass.text!
        
        if(newNameStr.isEmpty || passForNewGroupStr.isEmpty || confirmPassStr.isEmpty){
            self.view.makeToast("At least one field is empty", duration: 3.0, position: .center)
        }else if(passForNewGroupStr != confirmPassStr){
            self.view.makeToast("confirm password not equal to password", duration:3.0, position: .center)
            
        }else{
            
            refGroup.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.hasChild(self.newNameStr){
                    self.view.makeToast("\(self.newNameStr!) already exist", duration: 3.0 ,position: .center)
                    print("\(self.newNameStr!) already exist")
                    
                }else{
                    
                    print("\(self.newNameStr!) created as a new Group")
                    self.refGroup.child(self.newNameStr).child("Password").setValue(self.passForNewGroupStr)
                    self.performSegue(withIdentifier: "toHomePage", sender: self)
                    self.txtNewName.text = ""
                    self.txtPassForNewGroup.text = ""
                    self.txtConfirmPass.text = ""
                    self.txtGroupName.text = ""
                    self.txtGroupPass.text = ""
                }
                
                
            })
            
            
        }
    }
    
    @IBAction func btnViewGroupSelection(_ sender: UIButton) {
        groupNameForViewSelectionStr = txtGroupNameForViewSelection.text!
        refSelection = ref.child("Groups").child(groupNameForViewSelectionStr)
        
        if(groupNameForViewSelectionStr.isEmpty){
            self.view.makeToast("Field Is Empty", duration: 3.0, position: .center)
        }else{
            refSelection?.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    self.performSegue(withIdentifier: "toViewGroupSelection", sender: self)
                    print("selection exist in firebase -> show view last selection row")
                }else{
                    self.view.makeToast("There Isn't Such A Group Name", duration: 3.0, position: .center)
                }
            })
        }
        
    }
    
    /**
     * Called when 'return' key pressed and make keyboard disappear. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignIn"{
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
        
        if segue.identifier == "toHomePage"{
            let nextScrn = segue.destination as! HomePageViewController;
            if(groupNameStr != nil){
                nextScrn.setMsg(groupName: groupNameStr);
            }else{
                nextScrn.setMsg(groupName: newNameStr);
            }
        }
        
        if segue.identifier == "toViewGroupSelection"{
            let nextScrn = segue.destination as! GroupSelectionViewController;
            nextScrn.setMsg(groupName: groupNameForViewSelectionStr);
        }
        
        //if segue.identifier == "toViewGroupSelection"{
          //  var DestViewController = segue.destination as! UINavigationController
            //let targetController = DestViewController.topViewController as! GroupSelectionViewController
            //targetController.data = "hello from ReceiveVC !"
        //}
        
    }
    

}
