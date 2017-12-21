//
//  CollectionController.swift
//  DropIn
//
//  Created by Kaden Oldham on 12/5/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

extension CollectionController {
    
    static let collectionChangeNotification = Notification.Name("collectionChangeNotification")
    static let collectionImagesChangeNotificaton = Notification.Name("CollectionImagesWereAdded")
    
}

class CollectionController {
    
    //MARK: - singleton
    static let shared = CollectionController()
    
    //MARK: - collectinons
    var collection: Collection?
    var collections = [Collection]() {
        didSet {
            let nc = NotificationCenter.default
            nc.post(name: CollectionController.collectionChangeNotification, object: self)
        }
    }
    var collectionImages = [Collection]() {
        didSet {
            let nc = NotificationCenter.default
            nc.post(name: CollectionController.collectionImagesChangeNotificaton, object: self)
        }
    }
    
    //MARK: - cloudKitManager
    let cloudKitManager: CloudKitManager
    
    //MARK: - init
    init() {
        self.cloudKitManager = CloudKitManager()
    }
    
    //MARK: - create
    func createCollection(name: String, completion: @escaping (_ success: Bool) -> Void = { _ in }) {
        guard let currentUser = UserController.shared.currentUser,
            let userRecordID = currentUser.cloudKitRecordID else { return }
        let ownerReference = CKReference(recordID: userRecordID, action: .none)
        let collection = Collection(collectionName: name, owner: currentUser, ownerRefrence: ownerReference)
        currentUser.collections?.append(collection)
        let record = CKRecord(collection)
        cloudKitManager.saveRecord(record) { (_, error) in            
            if let error = error {
                print("error, could not save record, \(error.localizedDescription)")
                completion(false)
                return
            }
            collection.ckrecordID = record.recordID
            DispatchQueue.main.async {
                print("creating a collection")
                completion(true)
            }
        }
    }
    
    //MARK: - fetch
    func fetchNewCollectionRecords(ofType type: String, completion: @escaping ((Bool) -> Void) = {_ in }) {
        var predicate: NSPredicate?
        if type == User.recordTypeKey {
            predicate = NSPredicate(value: true)
        } else if type == Collection.collectionTypeKey {
            let predicate2 = NSPredicate(value: true)
            predicate = predicate2
            cloudKitManager.fetchRecordsWithType(type, predicate: predicate2, recordFetchedBlock: nil, completion: { (records, error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(false); return
                }
                guard let records = records else { completion(false); return}
                switch type {
                case User.recordTypeKey:
                    let users = records.flatMap { User(cloudKitRecord: $0)}
                    UserController.shared.users = users
                    completion(true)
                case Collection.collectionTypeKey:
                    let collections = records.flatMap { Collection(ckRecord: $0)}
                    self.collections = collections
                    for collection in (self.collections) {
                        let users = UserController.shared.users
                        guard let ownerID = collection.ownerRefrence?.recordID else {print("Can not find ownerRecord id"); return }
                        guard let collectionOwner = users.filter({$0.cloudKitRecordID == ownerID}).first else { break }
                        collection.owner = collectionOwner
                    }
                    self.collections = collections
                    completion(true)
                default:
                    print("can not fetch Collections")
                    return
                }
                for collection in self.collections {
                    UserController.shared.currentUser?.collections = self.collections
                    for image in collection.photoArray {
                        self.collection?.photoArray.append(image)
                    }
                }
                completion(true)
            })
        }
    }
    
    //MARK: - removes
    func removeCollection(collection: Collection) {
        guard let index = collections.index(of: collection) else { return }
        self.collections.remove(at: index)
    }
    func deleteCollection(collection: Collection, completion: @escaping(() -> Void) = {}) {
        guard let record = collection.ckrecordID else { return }
        self.cloudKitManager.deleteRecordWithID(record) { (_, error) in
            if let error = error { print("error deleting collection \(error.localizedDescription)"); return}
        }
        guard let index = UserController.shared.currentUser?.collections?.index(of: collection) else { return }
        UserController.shared.currentUser?.collections?.remove(at: index)
    }
    func deleteImage(image: UIImage, fromCollection collection: Collection, completion: @escaping (() -> Void) = {}) {
        // TODO - Test
        guard let curentUser = UserController.shared.currentUser else { return }
        guard let userRecordID = curentUser.cloudKitRecordID else { return }
        let ownerRefrence = CKReference(recordID: userRecordID, action: .none)
        guard let index = collection.photoArray.index(of: image) else { print("no image"); completion(); return }
        collection.photoArray.remove(at: index)
        collection.ownerRefrence = ownerRefrence
        let curentCollectionRecord = CKRecord(collection)
        cloudKitManager.modifyRecords([curentCollectionRecord], perRecordCompletion: nil) { (_, error) in
            if let error = error { print("error \(error.localizedDescription)") }
                NotificationCenter.default.post(name: CollectionController.collectionImagesChangeNotificaton, object: self)
                completion()
                return
        }
        
    }
    
    
    //MARK: - saves
    func saveText(to collection: Collection, text: String, completion: @escaping (Collection) -> Void) {
        collection.text = text
        guard let recordID = collection.ckrecordID else { return }
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let error = error { NSLog("error fetching the recordID \(error.localizedDescription)")}
            guard let record = record else { return }
            record.setValue(text, forKey: Collection.textKey)
            record.changedKeys()
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            modifyOperation.savePolicy = .changedKeys
            modifyOperation.modifyRecordsCompletionBlock = { (records, _, error) in
                if let error = error { NSLog("Error modifying thr record: \(error.localizedDescription)")
                    return
                }
                guard let record = records?.first else { return }
                guard let collection = Collection(ckRecord: record) else { return }
                completion(collection)
            }
            CKContainer.default().privateCloudDatabase.add(modifyOperation)
        }
    }
    func uploadRecords(to collection: Collection, images: [UIImage], completion: @escaping (_ success: Bool) -> Void) {
        guard let curentUser = UserController.shared.currentUser else { return }
        guard let userRecordID = curentUser.cloudKitRecordID else { return }
        let ownerRefrence = CKReference(recordID: userRecordID, action: .none)
        collection.ownerRefrence = ownerRefrence
        let curentCollectionRecord = CKRecord(collection)
        self.cloudKitManager.modifyRecords([curentCollectionRecord], perRecordCompletion: nil) { (_, error) in
            if let error = error {
                print("error modifying Records \(error.localizedDescription)")
                completion(false)
                return
            } else {
                print("successfully modifyed record")
            }
            completion(true)
        }
    }
}












