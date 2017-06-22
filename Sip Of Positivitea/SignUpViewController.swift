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
    
    private lazy var usersRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    private lazy var conversationsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("conversations")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccountAction(_ sender: AnyObject) {
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
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: phoneNumberTextField.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")

                    let defaults = UserDefaults.standard
                    defaults.set(email, forKey:"user_email")
                    defaults.set(phone_number, forKey:"user_phonenumber")
                    defaults.set(first_name, forKey:"user_firstname")
                    defaults.set(last_name, forKey:"user_lastname")
                    let uid = user?.uid
                    let userReference = self.usersRef.child(uid!)
                    let isAllynn = (phone_number == "4044443833" && email == "allynntay@yahoo.com") ? "true" : "false"
                    let values = ["email":email,
                                  "phone_number": phone_number,
                                  "first_name": first_name,
                                  "last_name": last_name,
                                  "is_allynn": isAllynn]

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
                            let conversation = Conversation(id: "Allynn"+phone_number!,
                                                            first_name: first_name!,
                                                            last_name: last_name!,
                                                            phone_number: phone_number!,
                                                            last_received_message: Date(timeIntervalSince1970: 0 / 1000))
                                
                            self.performSegue(withIdentifier: "AccountCreated", sender: conversation)
                        }
                    })
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let conversation = sender as? Conversation {
            self.createConversation(firstName:conversation.first_name , lastName: conversation.last_name, phoneNumber: conversation.phone_number)
            
            let chatVc = segue.destination.childViewControllers[0] as! ChatViewController
            
            chatVc.senderDisplayName = "Allynn"
            chatVc.conversation = conversation
            chatVc.conversationRef = conversationsRef.child(conversation.id)
        }
    }

    func createConversation(firstName: String!, lastName: String!, phoneNumber:String!) {
        let newConversationRef = conversationsRef.child("Allynn"+phoneNumber)
        let conversationItem = [
            "first_name": firstName!,
            "last_name": lastName!,
            "phone_number": phoneNumber!,
            "last_received_message": 0,
        ] as [String : Any]
        newConversationRef.setValue(conversationItem) // 4
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
