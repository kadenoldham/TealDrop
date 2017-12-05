//
//  Collections.swift
//  DropIn
//
//  Created by Kaden Oldham on 12/5/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import Foundation
import CloudKit

class Collection {
    static let collectionTypeKey = "Collection"
    static let collectionNameKey = "collectionName"
    static let ownerKey = "owner"
    static let ownerRefrenceKey = "ckRefrence"
    static let recordIDKey = "recordID"
    
    var collectionName: String?
    var owner: User?
    var ownerRefrence: CKReference?
    var ckrecordID: CKRecordID?
    
    init(collectionName: String?, owner: User?, ownerRefrence: CKReference?) {
        
        self.collectionName = collectionName
        self.owner = owner
        self.ownerRefrence = ownerRefrence
        
    }
    
    init?(ckRecord: CKRecord) {
        
        guard let collectionName = ckRecord[Collection.collectionNameKey] as? String,
            let owner = ckRecord[Collection.ownerKey] as? User,
            let ownerReference = ckRecord[Collection.ownerRefrenceKey] as? CKReference else { return }
        
        self.collectionName = collectionName
        self.owner = owner
        self.ownerRefrence = ownerReference
        self.ckrecordID = ckRecord.recordID
    
    }
    
}

extension CKRecord {
    convenience init(_ collection: Collection) {
        
        let recordID = collection.ckrecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: Collection.collectionTypeKey, recordID: recordID)
        
        self.setValue(collection.collectionName, forKey: Collection.collectionNameKey)
        self.setValue(collection.owner, forKey: Collection.ownerKey)
        self.setValue(collection.ownerRefrence, forKey: Collection.ownerRefrenceKey)
        
        
    }
}










