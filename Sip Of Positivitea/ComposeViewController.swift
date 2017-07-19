//
//  ComposeViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 7/14/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var textInput:UITextView!
    
    var doneHandler:((UITextView?) -> Void)?
    var newMassMessage: MassMessage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (newMassMessage != nil) {
            textInput.text = newMassMessage?.messageContent
            textInput.textColor = UIColor.darkGray
        } else {
            textInput.text = "New Message..."
            textInput.textColor = UIColor.lightGray
        }

        // Do any additional setup after loading the view.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.darkGray
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        doneHandler?(textInput)
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
