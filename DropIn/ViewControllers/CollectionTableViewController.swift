//
//  CollectionTableViewController.swift
//  DropIn
//
//  Created by Kaden Oldham on 12/4/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import UIKit

class CollectionTableViewController: UITableViewController {
    
    var currentUser = UserController.shared.currentUser
    
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
                let _ = self.currentUser else { print("\(self.currentUser?.username ?? "no current user")"); return }
            
            CollectionController.shared.createCollection(name: title, completion: { (success) in
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
        CollectionController.shared.fetchNewCollectionRecords(ofType: "Collection") {
            DispatchQueue.main.async {
                print("fetching collection records")
                self.tableView.reloadData()
            }
        }
        
    }
    
    private func setUpViews() {
        
        DispatchQueue.main.async {
            self.navigationTitle.title = UserController.shared.currentUser?.username ?? "No user name"
            //            CollectionController.shared.loadCollectionsFromiCloud()
            print(UserController.shared.currentUser?.username ?? "No username")
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return UserController.shared.currentUser?.collections.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionsCell", for: indexPath)
        
        guard let collection = currentUser?.collections[indexPath.row] else { return UITableViewCell()}
        
        
        cell.textLabel?.text = collection.collectionName
        
        return cell
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let collection = UserController.shared.currentUser?.collections[indexPath.row] else { return }
            CollectionController.shared.deleteCollection(collection: collection, completion: {
                print("\(String(describing: collection.owner?.collections.count))")
            })
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        
        }
    }
    
    
     // MARK: - Navigation
     
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toImageCollection"{
            
            if let collection = segue.destination as? ImageCollectionViewController, let indexPath = tableView.indexPathForSelectedRow {
                
                collection.collection = currentUser?.collections[indexPath.row]
                
                
            }
            
        }
        
        
     }
 
    
}
