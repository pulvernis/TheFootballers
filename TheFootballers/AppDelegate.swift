//
//  AppDelegate.swift
//  TheFootballers
//
//  Created by Ran Pulvernis on 27/01/2017.
//  Copyright © 2017 RanPulvernis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    override init() {
        super.init()
        // Use Firebase library to configure APIs
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                    annotation: [:])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        // ...
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            print("User got Signed in Firebase")
            self.handleLogin()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // i'll sign out user later
        print("im out google from app delegate")
        handleLogOut()
    }
    
    func handleLogin(){
        showSignInToGroupViewController()
    }
    
    func showSignInToGroupViewController(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let PostView: AnyObject! = storyboard.instantiateViewController(withIdentifier: "AfterLoginVC")
        
        let rootViewController = self.window!.rootViewController as! UINavigationController
        rootViewController.pushViewController(PostView as! UIViewController, animated: true)
        print("im in SignInToGroupVC from appdelegate")
        
    }
    
    func handleLogOut(){
        GIDSignIn.sharedInstance().signOut()
        print("sign out google from appDelegate")
        try! FIRAuth.auth()?.signOut()
        print("sign out firebase from appDelegate")
        showLogginViewController()
        
    }
    
    func showLogginViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let PostView: AnyObject! = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        
        let rootViewController = self.window!.rootViewController as! UINavigationController
        rootViewController.pushViewController(PostView as! UIViewController, animated: true)
        print("move back to sign in vc from app delegate")
    }

}
