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
    private var conversationsUnsortedData : [String:Conversation] = [:]
    private var conversations : [Conversation] = []
    private lazy var conversationsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("conversations")
    private var conversationsRefHandle: FIRDatabaseHandle?
    private var conversationsChangedHandle: FIRDatabaseHandle?

    private var isAllynn : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Messages"
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
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm a"
        cell.detailTextLabel?.text = formatter.string(from:convo.last_received_message)
        if convo.read_messages {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.detailDisclosureButton
        }
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
            
            chatVc.senderDisplayName = "Allynn"
            chatVc.conversation = conversation
            chatVc.conversationRef = conversationsRef.child(conversation.id)
            chatVc.receiver_user_id = conversation.receiver_user_id
            chatVc.isAllynn = "true"
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
            let receiver_user_id = conversationData["receiver_user_id"] as? String ?? ""
            let read_messages = conversationData["allynn_read_messages"] as? Bool ?? false
            
            if first_name.characters.count > 0 {
                self.conversationsUnsortedData[phone_number] = Conversation(id: id,
                                                                       first_name: first_name,
                                                                       last_name: last_name,
                                                                       phone_number: phone_number,
                                                                       last_received_message: Date(timeIntervalSince1970: date / 1000),
                                                                       receiver_user_id: receiver_user_id, read_messages: read_messages)
                self.conversations.append(self.conversationsUnsortedData[phone_number]!)
                self.conversations.sort {
                    $0.last_received_message.compare($1.last_received_message) == ComparisonResult.orderedDescending
                }
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode conversation data")
            }
        })
        
        conversationsChangedHandle = conversationsRef.observe(.childChanged, with: {(snapshot) -> Void in
            let conversationData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key;
            let first_name = conversationData["first_name"] as! String
            let last_name = conversationData["last_name"] as! String
            let phone_number = conversationData["phone_number"] as! String
            let date = conversationData["last_received_message"] as! TimeInterval
            let receiver_user_id = conversationData["receiver_user_id"] as? String ?? ""
            let read_messages = conversationData["allynn_read_messages"] as? Bool ?? false

            self.conversationsUnsortedData[phone_number] = Conversation(id: id,
                                                                        first_name: first_name,
                                                                        last_name: last_name,
                                                                        phone_number: phone_number,
                                                                        last_received_message: Date(timeIntervalSince1970: date / 1000),
                                                                        receiver_user_id:receiver_user_id, read_messages: read_messages)
            self.conversations.removeAll()
            self.conversations.append(contentsOf: self.conversationsUnsortedData.values)
            self.conversations.sort {
                $0.last_received_message.compare($1.last_received_message) == ComparisonResult.orderedDescending
            }
            self.tableView.reloadData()
        })
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
