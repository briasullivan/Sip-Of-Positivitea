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
    private lazy var usersRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    private lazy var conversationsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("conversations")
    private var userRefHandle: FIRDatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //get the currently signed-in user by using the currentUser property. If a user isn't signed in, currentUser is nil:
        if let curUser = FIRAuth.auth()?.currentUser {
            // User is signed in.
            print("start current user: " + curUser.email! )
            self.loginToApp(user: curUser)

        } else {
            // No current user is signed in.
            print("Currently, no user is signed in.")
        }
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
            
            FIRAuth.auth()?.signIn(withEmail: email!, password: phone_number!) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                   self.loginToApp(user: user!)
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func loginToApp(user: FIRUser) {
        let uid = user.uid
        let userReference = self.usersRef.child(uid)
        userReference.observeSingleEvent(of: .value, with:{ (snapshot) in
            let value = snapshot.value as? NSDictionary
            let is_allynn = value?["is_allynn"] as? String ?? ""
            let phone_number = value?["phone_number"] as? String ?? ""
            if is_allynn == "true" {
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
            chatVc.senderDisplayName = "Allynn"
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
