//
//  ContactsListTableViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 4/23/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

enum Section: Int {
    case groupsSection = 0
    case contactsSection
}

class ContactsListTableViewController: UITableViewController {
    private var groups : [Group] = []
    private var contacts : [Contact] = []
    private lazy var groupsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("groups")
    private lazy var contactsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    private var contactsRefHandle: FIRDatabaseHandle?
    private var groupsRefHandle: FIRDatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        observeContacts()
        observeGroups()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

            if first_name.characters.count > 0 && phone_number != "4044443833"{ // 3
                self.contacts.append(
                    Contact(id: id,
                            first_name: first_name,
                            last_name: last_name,
                            phone_number: phone_number,
                            email: email))
                self.contacts.sort {
                    ($0.first_name + " " + $0.last_name).compare($1.first_name + " " + $1.last_name) == ComparisonResult.orderedAscending
                }
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .groupsSection:
                return groups.count
            case .contactsSection:
                return contacts.count
            }
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.groupsSection.rawValue ? "Group" : "Contact"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.groupsSection.rawValue {
            cell.textLabel?.text = groups[(indexPath as NSIndexPath).row].name
        } else if (indexPath as NSIndexPath).section == Section.contactsSection.rawValue {
            let contact = contacts[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = contact.first_name + " " + contact.last_name
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .groupsSection:
                return "Groups"
            case .contactsSection:
                return "Contacts"
            }
        } else {
            return "Contacts"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if (indexPath.section == 1) {
            let contactVC = storyboard.instantiateViewController(withIdentifier: "Contact") as! ContactTableViewController
            contactVC.contact = contacts[indexPath.row]
            self.show(contactVC, sender: self)
        }
    }
    
    // MARK :Actions
    @IBAction func createContact(_ sender: AnyObject) {
       /* if let name = newChannelTextField?.text { // 1
            let newChannelRef = channelRef.childByAutoId() // 2
            let channelItem = [ // 3
                "name": name
            ]
            newChannelRef.setValue(channelItem) // 4
        }*/
    }
    
    // MARK :Actions
    @IBAction func createGroup(_ sender: AnyObject) {

    }
    
    deinit {
        if let refHandle = groupsRefHandle {
            groupsRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = contactsRefHandle {
            contactsRef.removeObserver(withHandle: refHandle)
        }
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
