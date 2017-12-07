//
//  CollectionController.swift
//  DropIn
//
//  Created by Kaden Oldham on 12/5/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import Foundation
import CloudKit

extension CollectionController {
    
    static let collectionChangeNotification = Notification.Name("collectionChangeNotification")
    
    
}

class CollectionController {

    static let shared = CollectionController()
    
    var collection: Collection?
    
    var collections = [Collection]() {
        didSet {
            let nc = NotificationCenter.default
            nc.post(name: CollectionController.collectionChangeNotification, object: self)
            
        }
    }
    
    let cloudKitManager: CloudKitManager
    
    init() {
        self.cloudKitManager = CloudKitManager()
    }
    
    // - MARK - CRUD
    
    func createCollection(name: String, completion: @escaping (_ success: Bool) -> Void = { _ in }) {
        guard let currentUser = UserController.shared.currentUser,
            let userRecordID = currentUser.cloudKitRecordID else { return }
        let ownerReference = CKReference(recordID: userRecordID, action: .none)
        let collection = Collection(collectionName: name, owner: currentUser, ownerRefrence: ownerReference)
        currentUser.collections.append(collection)
        let record = CKRecord(collection)
        cloudKitManager.saveRecord(record) { (_, error) in
            
            if let error = error {
                print("error, could not save record, \(error.localizedDescription)")
                completion(false)
                return
            }
            DispatchQueue.main.async {
                print("creating a collection")
                completion(true)
            }
        }
    }
    
    private func loadFromPersistentStorage() {
        
        
        
        
        
    }
}












