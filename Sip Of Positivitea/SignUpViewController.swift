//
//  SignUpViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 4/23/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    private lazy var usersRef: DatabaseReference = Database.database().reference().child("users")
    private lazy var conversationsRef: DatabaseReference = Database.database().reference().child("conversations")
    private lazy var allynnRef: DatabaseReference = Database.database().reference().child("allynn")
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelCreate(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAccountAction(_ sender: AnyObject) {
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

        let email = emailTextField.text
        let phone_number = phoneNumberTextField.text
        let first_name = firstNameTextField.text
        let last_name = lastNameTextField.text
        
        if (email == "" || phone_number == "" || first_name == "" || last_name == "") {
            var errorMessage = "Please enter your "
            var errors = [String]()
            
            if (emailTextField.text == "") {
                errors.append("email")
            }
            if (phoneNumberTextField.text == "") {
                errors.append("phone number")
            }
            if (firstNameTextField.text == "") {
                errors.append("first name")
            }
            if (lastNameTextField.text == "") {
                errors.append("last name")
            }
            for error in errors {
                errorMessage += (error + ", ")
            }
            let index = errorMessage.index(errorMessage.endIndex, offsetBy:-2)
            errorMessage = errorMessage.substring(to: index)
            let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            blurView.removeFromSuperview()
            loadingHolderView.removeFromSuperview()
            present(alertController, animated: true, completion: nil)
            
        } else {
            let numbersOnly = String(phone_number!.characters.filter { "0123456789".characters.contains($0) })
            Auth.auth()?.createUser(withEmail: emailTextField.text!, password: numbersOnly) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")

                    let defaults = UserDefaults.standard
                    defaults.set(email, forKey:"user_email")
                    defaults.set(numbersOnly, forKey:"user_phonenumber")
                    defaults.set(first_name, forKey:"user_firstname")
                    defaults.set(last_name, forKey:"user_lastname")
                    let uid = user?.uid
                    let userReference = self.usersRef.child(uid!)
                    let isAllynn = (phone_number == "4044443833" && email == "allynntay@yahoo.com") ? "true" : "false"
                    defaults.set(isAllynn, forKey: "is_allynn")

                    let values = ["email":email,
                                  "phone_number": numbersOnly,
                                  "first_name": first_name,
                                  "last_name": last_name,
                                  "is_allynn": isAllynn,
                                  "notification_user_id": "no_id"]

                    userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                        if isAllynn == "true" {
                            self.performSegue(withIdentifier: "AllynnAccountCreated", sender: nil)
                        } else {
                            let conversation = Conversation(id: "Allynn"+numbersOnly,
                                                            first_name: first_name!,
                                                            last_name: last_name!,
                                                            phone_number: numbersOnly,
                                                            last_received_message: Date(timeIntervalSince1970: 0 / 1000),
                                                            receiver_user_id: uid!,read_messages:true)
                                
                            self.performSegue(withIdentifier: "AccountCreated", sender: conversation)
                        }
                    })
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                blurView.removeFromSuperview()
                loadingHolderView.removeFromSuperview()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let conversation = sender as? Conversation {
            self.createConversation(firstName:conversation.first_name , lastName: conversation.last_name, phoneNumber: conversation.phone_number, receiverUserId: conversation.receiver_user_id)
            
            let chatVc = segue.destination.childViewControllers[0] as! ChatViewController
            
            chatVc.senderDisplayName = "Chat with Allynn!"
            chatVc.conversation = conversation
            chatVc.isAllynn = "false"
            chatVc.conversationRef = conversationsRef.child(conversation.id)
            self.allynnRef.child("allynn_info").observeSingleEvent(of: .value, with: {(snapshot) in
                let value = snapshot.value as? NSDictionary
                if let allynnId = value?["user_id"] {
                    chatVc.receiver_user_id = (allynnId as! String)
                }
            })
        }
    }

    func createConversation(firstName: String!, lastName: String!, phoneNumber:String!, receiverUserId:String!) {
        let newConversationRef = conversationsRef.child("Allynn"+phoneNumber)
        let conversationItem = [
            "first_name": firstName!,
            "last_name": lastName!,
            "phone_number": phoneNumber!,
            "last_received_message": 0,
            "receiver_user_id": receiverUserId,
            "allynn_read_messages": true,
        ] as [String : Any]
        newConversationRef.setValue(conversationItem) // 4
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
