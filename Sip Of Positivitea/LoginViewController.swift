//
//  LoginViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 4/23/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    private lazy var usersRef: DatabaseReference = Database.database().reference().child("users")
    private lazy var allynnRef: DatabaseReference = Database.database().reference().child("allynn")
    private lazy var conversationsRef: DatabaseReference = Database.database().reference().child("conversations")
    private var userRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //get the currently signed-in user by using the currentUser property. If a user isn't signed in, currentUser is nil:

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        let email = self.emailTextField.text
        let phone_number = self.phoneNumberTextField.text
        
        if email == "" || phone_number == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            let loadingHolderFrame = CGRect(x:self.view.frame.size.width / 2 - 50, y: self.view.frame.size.height / 2 - 50, width: 100, height: 100)
            let loadingViewFrame = CGRect(x: 0, y: 0
                , width: 100, height: 100)
            let loadingView = MOOverWatchLoadingView(frame: loadingViewFrame, autoStartAnimation: true, color: UIColor.lightGray)
            let loadingHolderView = UIView(frame: loadingHolderFrame)
            loadingHolderView.addSubview(loadingView)
            let blurEffect = UIBlurEffect(style: .light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = self.view.bounds
            blurView.alpha = 0.7;
            self.view.addSubview(blurView)
            self.view.addSubview(loadingHolderView)
            let numbersOnly = String(phone_number!.characters.filter { "0123456789".characters.contains($0) })

            Auth.auth().signIn(withEmail: email!, password: numbersOnly) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    blurView.removeFromSuperview()
                    loadingHolderView.removeFromSuperview()
                   self.loginToApp(user: user!.user)
                    
                } else {
                    blurView.removeFromSuperview()
                    loadingHolderView.removeFromSuperview()
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func loginToApp(user: User) {
        let uid = user.uid
        let userReference = self.usersRef.child(uid)
        userReference.observeSingleEvent(of: .value, with:{ (snapshot) in
            let value = snapshot.value as? NSDictionary
            let is_allynn = value?["is_allynn"] as? String ?? ""
            let phone_number = value?["phone_number"] as? String ?? ""
            let defaults = UserDefaults.standard
            defaults.set(is_allynn, forKey: "is_allynn")
            defaults.synchronize()
            if is_allynn == "true" {
                self.allynnRef.child("allynn_info").child("user_id").setValue(uid)
                self.performSegue(withIdentifier: "AllynnLoginToApp", sender: nil)
            } else {
                self.performSegue(withIdentifier: "LoginToApp", sender:phone_number)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "LoginToApp" {
            let navController = segue.destination as! UINavigationController
            let chatVc = navController.viewControllers[0] as! ChatViewController;
            chatVc.senderDisplayName = "Chat with Allynn!"
            //chatVc.conversationRef = convoReference
            
            let phone_number = sender as! String
            let convoReference = self.conversationsRef.child("Allynn"+phone_number)
            convoReference.observeSingleEvent(of: .value, with: { (snapshot) in
                let conversationData = snapshot.value as! Dictionary<String, AnyObject>
                let first_name = conversationData["first_name"] as! String
                self.allynnRef.child("allynn_info").observeSingleEvent(of: .value, with: {(snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if let allynnId = value?["user_id"] {
                        chatVc.receiver_user_id = (allynnId as! String)
                    }
                })
                chatVc.senderDisplayName = first_name
                chatVc.conversationRef = convoReference
                chatVc.isAllynn = "false"
                chatVc.viewDidLoad()
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
