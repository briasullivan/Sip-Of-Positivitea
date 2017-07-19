//
//  NewMessageTableViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 7/8/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit

class NewMessageTableViewController: UITableViewController {
    private var newMassMessage:MassMessage!
    
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
            if (newMassMessage != nil) {
                cell.textLabel?.text = newMassMessage.messageContent
            } else {
                cell.textLabel?.text = "Compose a new message"
            }
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "AddPhotosCell", for: indexPath)
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
        }
    }
    
    func didSetMassMessage(input: UITextView?) {
        if (input != nil && (input?.text.characters.count)! > 0) {
            newMassMessage = MassMessage(messageContent: (input?.text)!)
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            newMassMessage = nil
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        tableView.reloadData()
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
