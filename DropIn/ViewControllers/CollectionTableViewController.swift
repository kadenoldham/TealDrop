//
//  CollectionTableViewController.swift
//  DropIn
//
//  Created by Kaden Oldham on 12/4/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import UIKit

class CollectionTableViewController: UITableViewController {
    
    private var currentUser: User?
    
    @IBAction func addCollectionButtonTapped(_ sender: Any) {
        
        var collectionNameTextField: UITextField?
        
        let alert = UIAlertController(title: "Create collection", message: "Name your collection.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            collectionNameTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            
            guard let title = collectionNameTextField?.text, title != "",
                let user = self.currentUser else { return }

            CollectionController.shared.createCollection(name: title, owner: user, completion: { (success) in
                if !success {
                    print("unable to create a collection")
                } else {
                    print("successfully created a collection")
                }
                
            })
            self.tableView.reloadData()
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        
    }
    
    private func setUpViews() {
        
        DispatchQueue.main.async {
            self.navigationTitle.title = UserController.shared.currentUser?.username ?? "No user name"
            print(UserController.shared.currentUser?.username ?? "No username")
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.currentUser?.collections.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionsCell", for: indexPath)
        
        guard let user = currentUser else { return UITableViewCell()}
        let collection = user.collections[indexPath.row]
        
        cell.textLabel?.text = collection?.collectionName
        
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
