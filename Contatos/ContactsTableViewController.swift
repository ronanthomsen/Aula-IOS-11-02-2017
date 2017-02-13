//
//  ContactsTableViewController.swift
//  Contatos
//
//  Created by Usuário Convidado on 11/02/17.
//  Copyright © 2017 FIAP. All rights reserved.
//

import UIKit
import Contacts

class ContactsTableViewController: UITableViewController {

    // MARK: - Properties
    var dataSource: [CNContact] = []
    var contactStore: CNContactStore {
        return (UIApplication.shared.delegate as! AppDelegate).contactStore
    }
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        checkAccess()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkAccess() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
            case .authorized:
                print("Autorização já concedida")
                listContacts()
            case .denied:
                print("Autorização negou")
            case.notDetermined:
                print("Vamos pedir autorização")
                requestAccess()
            case .restricted:
                print("Fodeu, não posso fazer nada")
        }
    }
    
    func requestAccess() {
        contactStore.requestAccess(for: .contacts) { (success: Bool, error: Error?) in
            if error == nil && success {
                print("Acesso liberado")
                DispatchQueue.main.async {
                    self.listContacts()
                }
            } else {
                print("Ocorreu algum erro.")
            }
        }
    }
    
    func listContacts() {
        dataSource.removeAll()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactImageDataKey] as [Any]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        
        do {
            try contactStore.enumerateContacts(with: fetchRequest) { (contact: CNContact, pointer: UnsafeMutablePointer<ObjCBool>) in
                self.dataSource.append(contact)
            }
            self.tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        
        
        /*
         //Jeito vida-loka
        try! contactStore.enumerateContacts(with: fetchRequest) { (contact: CNContact, pointer: UnsafeMutablePointer<ObjCBool>) in
            self.dataSource.append(contact)
        }
        */
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableViewCell

        cell.clear()
        
        let contact = dataSource[indexPath.row]

        if contact.isKeyAvailable(CNContactFamilyNameKey) && contact.isKeyAvailable(CNContactGivenNameKey) {
            cell.lbName.text = "\(contact.givenName) \(contact.familyName)"
        }
        
        for phoneNumber in contact.phoneNumbers {
            cell.lbPhones.text?.append("\(phoneNumber.value.stringValue)\n")
        }
        cell.lbPhones.text = cell.lbPhones.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        for email in contact.emailAddresses {
            cell.lbEmails.text?.append("\(email.value)\n")
        }
        cell.lbEmails.text = cell.lbEmails.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let imageData = contact.imageData {
            cell.ivProfile.image = UIImage(data: imageData)
        }
        
        return cell
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
