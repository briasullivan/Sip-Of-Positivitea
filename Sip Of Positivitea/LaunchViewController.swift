//
//  LaunchViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 7/11/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LaunchViewController: UIViewController {
    private lazy var usersRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    private lazy var conversationsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("conversations")
    private var userRefHandle: FIRDatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        let loadingHolderFrame = CGRect(x:self.view.frame.size.width / 2 - 50, y: self.view.frame.size.height / 2 - 50, width: 100, height: 100)
        let loadingViewFrame = CGRect(x: 0, y: 0
            , width: 100, height: 100)
        let loadingView = MOOverWatchLoadingView(frame: loadingViewFrame, autoStartAnimation: true, color: UIColor.white)
        var loadingHolderView = UIView(frame: loadingHolderFrame)
        loadingHolderView.addSubview(loadingView)
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.alpha = 0.7;
        self.view.addSubview(blurView)
        self.view.addSubview(loadingHolderView)
        
        if let curUser = FIRAuth.auth()?.currentUser {
            // User is signed in.
            print("start current user: " + curUser.email! )
            self.loginToApp(user: curUser)
            
            
        } else {
            // No current user is signed in.
            print("Currently, no user is signed in.")
            blurView.removeFromSuperview()
            loadingHolderView.removeFromSuperview()
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "showLoginPage", sender:self)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginToApp(user: FIRUser) {
        let uid = user.uid
        let userReference = self.usersRef.child(uid)
        userReference.observeSingleEvent(of: .value, with:{ (snapshot) in
            let value = snapshot.value as? NSDictionary
            let is_allynn = value?["is_allynn"] as? String ?? ""
            let phone_number = value?["phone_number"] as? String ?? ""
            if is_allynn == "true" {
                self.performSegue(withIdentifier: "launchToAllynnLogin", sender: nil)
            } else {
                self.performSegue(withIdentifier: "launchToUserLogin", sender:phone_number)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "launchToUserLogin" {
            let navController = segue.destination as! UINavigationController
            let chatVc = navController.viewControllers[0] as! ChatViewController;
            chatVc.senderDisplayName = "Chat with Allynn!"
            //chatVc.conversationRef = convoReference
            
            let phone_number = sender as! String
            let convoReference = self.conversationsRef.child("Allynn"+phone_number)
            convoReference.observeSingleEvent(of: .value, with: { (snapshot) in
                let conversationData = snapshot.value as! Dictionary<String, AnyObject>
                let first_name = conversationData["first_name"] as! String
                
                chatVc.senderDisplayName = first_name
                chatVc.conversationRef = convoReference
                chatVc.viewDidLoad()
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
