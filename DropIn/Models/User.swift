//
//  User.swift
//  Users
//
//  Created by Kaden Oldham on 12/1/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    static let usernameKey = "username"
    static let emailKey = "email"
    static let appleUserRefKey = "appleUserRef"
    static let recordTypeKey = "User"
    static let collectionNameKey = "collectionName"
    
    
    var username: String
    var email: String
    
    var collections: [Collection?]

    
    let appleUserRef: CKReference
    
    var cloudKitRecordID: CKRecordID?
    
    init(username: String, email: String, appleUserRef: CKReference, collectionNames: [Collection?] = []) {
        
        self.username = username
        self.email = email
        self.appleUserRef = appleUserRef
        self.collections = collectionNames
        
        
    }
    
    init?(cloudKitRecord: CKRecord) {
        
        guard let username = cloudKitRecord[User.usernameKey] as? String,
        let email = cloudKitRecord[User.emailKey] as? String,
            let appleUserRef = cloudKitRecord[User.appleUserRefKey] as? CKReference else { return nil }
        
        self.username = username
        self.email = email
        self.appleUserRef = appleUserRef
        self.cloudKitRecordID = cloudKitRecord.recordID
        
        if let collectionNames = cloudKitRecord[User.collectionNameKey] as? Collection{
            self.collections = [collectionNames]
        } else {
            self.collections = []
        }
    }

}

extension CKRecord {
    
    convenience init(user: User) {
        
        let recordID = user.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: User.recordTypeKey, recordID: recordID)
        
        self.setValue(user.username, forKey: User.usernameKey)
        self.setValue(user.email, forKey: User.emailKey)
        self.setValue(user.collections, forKey: User.collectionNameKey)
        self.setValue(user.appleUserRef, forKey: User.appleUserRefKey)
    }
    
}















