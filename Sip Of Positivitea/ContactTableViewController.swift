//
//  ContactTableViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 7/14/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController {
    var contact: Contact?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Name"
        case 1:
            return "Phone Number"
        case 2:
            return "Email"
        default:
            return ""
        }
    }
    
     
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = (contact?.first_name)! + " " + (contact?.last_name)!
            break;
        case 1:
            cell.textLabel?.text = formatPhoneNumber(phone_number:(contact?.phone_number)!)
            break;
        case 2:
            cell.textLabel?.text = contact?.email
        default:
            cell.textLabel?.text = ""
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }
    
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if (action == #selector(copy(_:))) {
            let cell = self.tableView.cellForRow(at: indexPath)
            UIPasteboard.general.string = cell?.textLabel?.text
        }
    }
    
    func formatPhoneNumber(phone_number:String) -> String {
        return String(format: "(%@) %@-%@",
                      phone_number.substring(to: phone_number.index(phone_number.startIndex, offsetBy: 3)),
                      phone_number.substring(with: phone_number.index(phone_number.startIndex, offsetBy: 3) ..< phone_number.index(phone_number.startIndex, offsetBy: 6)),
                      phone_number.substring(from: phone_number.index(phone_number.startIndex, offsetBy: 6
                      )))

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
