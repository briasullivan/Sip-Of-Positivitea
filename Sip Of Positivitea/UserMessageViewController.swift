//
//  UserMessageViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 4/23/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserMessageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutPressed(_ sender: AnyObject) {
        do {
            try FIRAuth.auth()!.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
            present(loginViewController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
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
