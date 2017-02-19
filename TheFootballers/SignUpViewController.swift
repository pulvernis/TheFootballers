//
//  SignUpViewController.swift
//  TheFootballers
//
//  Created by Ran Pulvernis on 27/01/2017.
//  Copyright © 2017 RanPulvernis. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtConfirmPass: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
}
    
    @IBAction func btnSignUp(_ sender: UIButton) {
        
        let emailStr:String = txtEmail.text!
        let passwordStr:String = txtPass.text!
        let confirmPassStr:String = txtConfirmPass.text!
        
        if(emailStr.isEmpty || passwordStr.isEmpty || confirmPassStr.isEmpty){
            self.view.makeToast("There is an empy field", duration: 3.0, position: .bottom)
        }else if(passwordStr != confirmPassStr){
            self.view.makeToast("password and confirm password not equal", duration: 3.0, position: .bottom)
        }else{
            
            FIRAuth.auth()?.createUser(withEmail: emailStr, password: passwordStr) { (user, error) in
                
                if error != nil {
                    
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            self.view.makeToast("Invalid Email", duration: 3.0, position: .bottom)
                        case .errorCodeEmailAlreadyInUse:
                            self.view.makeToast("Email already in use.. go to SignIn", duration: 3.0, position: .bottom)
                        default:
                            print(error!)
                            self.view.makeToast("SignUp User Error", duration: 3.0, position: .bottom)
                        }
                    }
                    
                } else {
                    
                    self.txtEmail.text = ""
                    self.txtPass.text = ""
                    self.txtConfirmPass.text = ""
                    
                    self.performSegue(withIdentifier: "toSignInToGroup", sender: self)
                    
                }
            }
            
        }
        
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSignInToGroupViewController"{
            let nextScrn = segue.destination as! SignInToGroupViewController;
            nextScrn.setMsg();
        }
    }
 */

}
