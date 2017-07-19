//
//  ChooseSendTableViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 7/14/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit
import OneSignal
import Firebase
import FirebaseDatabase

enum SendSection: Int {
    case sendToAll = 0
    case sendToGroup = 1
    case sendToContact = 2
}

class ChooseSendTableViewController: UITableViewController {
    var newMassMessage: MassMessage?
    private var groups : [Group] = []
    private var contacts : [Contact] = []
    private var conversationIdsToSend : [String] = []
    private var contactsToSend : [String:String] = [:]
    private var groupsToSend : [String:Bool] = [:]
    private var sendToAll : Bool = false

    private lazy var groupsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("groups")
    private lazy var contactsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    private lazy var conversationsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("conversations")
    private var contactsRefHandle: FIRDatabaseHandle?
    private var groupsRefHandle: FIRDatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButtonItem = UIBarButtonItem.init(
            title: "Send",
            style: .plain,
            target: self,
            action: #selector(ChooseSendTableViewController.sendPressed(sender:))
        )
        
        self.navigationItem.rightBarButtonItem = rightButtonItem
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        observeContacts()
        observeGroups()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func sendPressed(sender:UIBarButtonItem) {
        print("Send to users")
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
        
        if (newMassMessage == nil || newMassMessage?.messageContent.characters.count == 0) {
            return;
        }
        if (sendToAll) {
            var notificationIds : [String] = []
            for contact in contacts {
                if(contact.phone_number == "4044443833") {
                    continue;
                }
                let conversationId = "Allynn"+contact.phone_number
                let userConvoRef = self.conversationsRef.child(conversationId)
                let messageRef = userConvoRef.child("messages")
                let itemRef = messageRef.childByAutoId() // 1
                let messageItem = [ // 2
                    "senderId":  (FIRAuth.auth()?.currentUser?.uid)!,
                    "senderName": "Allynn",
                    "text": (newMassMessage?.messageContent)!,
                    "date": [".sv": "timestamp"],
                    ] as [String : Any]
                notificationIds.append(contact.notification_id)
                itemRef.setValue(messageItem)
            }
            OneSignal.postNotification(["headings": ["en":"Allynn"], "contents": ["en": (newMassMessage?.messageContent)!], "include_player_ids": notificationIds])
            
        } else {
            var notificationIds : [String] = []
            if (contactsToSend.count > 0) {
                for contact in contactsToSend.keys {
                    let conversationId = "Allynn"+contact
                    let userConvoRef = self.conversationsRef.child(conversationId)
                    let messageRef = userConvoRef.child("messages")
                    let itemRef = messageRef.childByAutoId() // 1
                    let messageItem = [ // 2
                        "senderId":  (FIRAuth.auth()?.currentUser?.uid)!,
                        "senderName": "Allynn",
                        "text": (newMassMessage?.messageContent)!,
                        "date": [".sv": "timestamp"],
                        ] as [String : Any]
                    notificationIds.append(contactsToSend[contact]!)
                    itemRef.setValue(messageItem)
                }
                OneSignal.postNotification(["headings": ["en":"Allynn"], "contents": ["en": (newMassMessage?.messageContent)!], "include_player_ids": notificationIds])
            }
            
            if (groupsToSend.count > 0) {
                
            }
        }
        
        loadingHolderView.removeFromSuperview()
        blurView.removeFromSuperview()
        self.navigationController?.popViewController(animated: true);
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: SendSection = SendSection(rawValue: section) {
            switch currentSection {
            case .sendToAll:
                return 1
            case .sendToGroup:
                return groups.count
            case .sendToContact:
                return contacts.count
            }
        } else {
            return 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentSection: SendSection = SendSection(rawValue: section) {
            switch currentSection {
            case .sendToAll:
                return ""
            case .sendToGroup:
                return "Groups"
            case .sendToContact:
                return "Contacts"
            }
        } else {
            return "Contacts"
        }
    }
    private func observeContacts() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        contactsRefHandle = contactsRef.observe(.childAdded, with: { (snapshot) -> Void in // 1
            let contactData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let id = snapshot.key
            let first_name = contactData["first_name"] as! String
            let last_name = contactData["last_name"] as! String
            let phone_number = contactData["phone_number"] as! String
            let email = contactData["email"] as! String
            let notification_id = contactData["notification_user_id"] as! String
            
            if first_name.characters.count > 0 && phone_number != "4044443833" { // 3
                self.contacts.append(
                    Contact(id: id,
                            first_name: first_name,
                            last_name: last_name,
                            phone_number: phone_number,
                            email: email,
                            notification_id: notification_id))
                self.contacts.sort {
                    ($0.first_name + " " + $0.last_name).compare($1.first_name + " " + $1.last_name) == ComparisonResult.orderedAscending
                }
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendCell", for: indexPath)
        if (indexPath.section == 0) {
            cell.textLabel?.text = "Send to All"
        } else if (indexPath.section == 1) {
            cell.textLabel?.text = groups[(indexPath as NSIndexPath).row].name
        } else if (indexPath.section == 2) {
            let contact = contacts[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = contact.first_name + " " + contact.last_name
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            if let currentSection: SendSection = SendSection(rawValue: indexPath.section) {
                switch currentSection {
                case .sendToAll:
                    sendToAll = true
                    break;
                case .sendToGroup:
                    groupsToSend[groups[indexPath.row].id] = true
                    break;
                case .sendToContact:
                    contactsToSend[contacts[indexPath.row].phone_number] = contacts[indexPath.row].notification_id
                    break;
                }
            }
        }
        
        if (sendToAll == true || groupsToSend.count > 0 || contactsToSend.count > 0) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            if let currentSection: SendSection = SendSection(rawValue: indexPath.section) {
                switch currentSection {
                case .sendToAll:
                    sendToAll = false
                    break;
                case .sendToGroup:
                    groupsToSend.removeValue(forKey: groups[indexPath.row].id)
                    break;
                case .sendToContact:
                    contactsToSend.removeValue(forKey:contacts[indexPath.row].phone_number)
                    break;
                }
            }
        }
        if (sendToAll == false && groupsToSend.count == 0 && contactsToSend.count == 0) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    private func observeGroups() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        groupsRefHandle = groupsRef.observe(.childAdded, with: { (snapshot) -> Void in // 1
            let groupsData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let id = snapshot.key
            if let name = groupsData["name"] as! String!, name.characters.count > 0 { // 3
                self.groups.append(Group(id: id, name: name))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }
    deinit {
        if let refHandle = groupsRefHandle {
            groupsRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = contactsRefHandle {
            contactsRef.removeObserver(withHandle: refHandle)
        }
    }

}
