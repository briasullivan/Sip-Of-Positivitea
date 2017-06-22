//
//  MessageListTableViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 4/23/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MessageListTableViewController: UITableViewController {
    var senderDisplayName: String?
    private var conversations : [Conversation] = []
    private lazy var conversationsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("conversations")
    private var conversationsRefHandle: FIRDatabaseHandle?

    private var isAllynn : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        title = "Sip of Positivitea"
        observeConversations()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.reloadData()
    }

    deinit {
        if let refHandle = conversationsRefHandle {
            conversationsRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Conversation", for: indexPath)

        let convo = conversations[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = convo.first_name + " " + convo.last_name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        self.performSegue(withIdentifier: "ShowMessages", sender: conversation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let conversation = sender as? Conversation {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = conversation.first_name
            chatVc.conversation = conversation
            chatVc.conversationRef = conversationsRef.child(conversation.id)
        }
    }
    
    private func observeConversations() {
        conversationsRefHandle = conversationsRef.observe(.childAdded, with: { (snapshot) -> Void in
            let conversationData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key;
            let first_name = conversationData["first_name"] as! String
            let last_name = conversationData["last_name"] as! String
            let phone_number = conversationData["phone_number"] as! String
            let date = conversationData["last_received_message"] as! TimeInterval
            
            if first_name.characters.count > 0 {
                self.conversations.append(
                    Conversation(id: id,
                                 first_name: first_name,
                                 last_name: last_name,
                                 phone_number: phone_number,
                                 last_received_message: Date(timeIntervalSince1970: date / 1000)))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode conversation data")
            }
        })
    }
    
    func signOut() {
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
