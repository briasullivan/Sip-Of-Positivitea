//
//  NewMessageTableViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 7/8/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit
import Photos

class NewMessageTableViewController: UITableViewController {
    private var newMassMessage:MassMessage! = MassMessage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightButtonItem = UIBarButtonItem.init(
            title: "Next",
            style: .plain,
            target: self,
            action: #selector(NewMessageTableViewController.nextPressed(sender:))
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        tableView.reloadData()
        //tableView.estimatedRowHeight = 150
        //tableView.rowHeight = UITableViewAutomaticDimension
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func nextPressed(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let chooseVC = storyboard.instantiateViewController(withIdentifier: "ChooseSend") as! ChooseSendTableViewController
        chooseVC.newMassMessage = newMassMessage
        self.show(chooseVC, sender: self)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewMessageCell", for: indexPath)
            if (newMassMessage.messageContent != nil) {
                cell.textLabel?.text = newMassMessage.messageContent
            } else {
                cell.textLabel?.text = "Compose a new message"
            }
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "AddPhotosCell", for: indexPath)
            if (newMassMessage.messageImage != nil) {
                cell.textLabel?.text = "Image included*"
            } else {
                cell.textLabel?.text = "Add Image to Message"
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            //self.performSegue(withIdentifier: "ShowComposeMessage", sender: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let composeVC = storyboard.instantiateViewController(withIdentifier: "Compose") as! ComposeViewController
            composeVC.newMassMessage = newMassMessage
            composeVC.doneHandler = {(inputTextView:UITextView?)-> Void in
                self.didSetMassMessage(input: inputTextView)
            }
            self.show(composeVC, sender: self)
        } else if (indexPath.section == 1) {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let addImageVC = storyboard.instantiateViewController(withIdentifier: "AddImage") as! AddImageViewController
            addImageVC.newMassMessage = newMassMessage
            addImageVC.doneHandler = {(inputImageView:UIImageView?)-> Void in
                self.didSetMassImage(input: inputImageView?.image)
            }
            self.show(addImageVC, sender: self)
        }
    }
    
    func didSetMassMessage(input: UITextView?) {
        if (input != nil && (input?.text.characters.count)! > 0) {
            newMassMessage.messageContent = (input?.text)!
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            newMassMessage.messageContent = nil
            if (newMassMessage.messageImage == nil) {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
        tableView.reloadData()
    }
    
    func didSetMassImage(input: UIImage?) {
        if (input != nil) {
            newMassMessage.messageImage = input!
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            newMassMessage.messageImage = nil
            if (newMassMessage.messageContent == nil){
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
        tableView.reloadData()
    }
}


