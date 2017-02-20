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
    @IBOutlet weak var googleLoginButton: GIDSignInButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        GIDSignIn.sharedInstance().uiDelegate = self
        googleLoginButton.style = .wide
        
        addImageViewToBackground()
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
                    }else {
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
        //add two textfields:
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
    
    private func addImageViewToBackground(){
        let imageName = "soccer_1.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: UIScreen.main.bounds.width/10, y: UIScreen.main.bounds.height*39/80, width: UIScreen.main.bounds.width*4/5, height: UIScreen.main.bounds.height/2)
        view.addSubview(imageView)
    }
    
}

