 //
//  Collections.swift
//  DropIn
//
//  Created by Kaden Oldham on 12/5/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class Collection {
    static let collectionTypeKey = "Collection"
    fileprivate let collectionNameKey = "collectionName"
    fileprivate let ownerKey = "owner"
    fileprivate let ownerRefrenceKey = "ckRefrence"
    fileprivate let recordIDKey = "recordID"
    fileprivate let photoDataKey = "photoData"
    static let textKey = "text"
    static let photoArrayKey = "photoArray"
    
    var text: String?
    var collectionName: String?
    var owner: User?
    var ownerRefrence: CKReference?
    var ckrecordID: CKRecordID?
    
    var photoArray: [UIImage] = []
    /// This is the acutal collection photos
    var collectionPhoto: Data?
    
    let photoData: Data?
    var photo: UIImage? {
        guard let photoData = self.photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    init(collectionName: String?, text: String = "", owner: User?, photoData: Data? = Data(), ownerRefrence: CKReference?, photoArray: [UIImage] = []) {
        
        self.photoData = photoData
        self.collectionName = collectionName
        self.owner = owner
        self.ownerRefrence = ownerRefrence
        self.photoArray = photoArray
        
        
    }
    
//    convenience init(collectionPhoto: Data?) {
//        self.collectionPhoto = collectionPhoto
//    }
    
    init?(ckRecord: CKRecord) {
        
        guard let collectionName = ckRecord[collectionNameKey] as? String,
            let ownerReference = ckRecord[ownerRefrenceKey] as? CKReference else { return nil }
        
        
        
        self.collectionName = collectionName
        self.owner = nil
        self.ownerRefrence = ownerReference
        self.ckrecordID = ckRecord.recordID
        
        if let text = ckRecord[Collection.textKey] as? String {
            self.text = text
        } else {
            self.text = ""
        }
        
        if let photoAsset = ckRecord[photoDataKey] as? CKAsset {
            self.photoData = try? Data(contentsOf: photoAsset.fileURL)
        } else {
            self.photoData = nil
        }
        var photoArray: [UIImage] = []
        
        if let photoAssetArray = ckRecord[Collection.photoArrayKey] as? [CKAsset] {
            
            for asset in photoAssetArray {
                
                guard let data = try? Data(contentsOf: asset.fileURL),
                    let image = UIImage(data: data) else { continue }
                photoArray.append(image)
            }
            
        }
        self.photoArray = photoArray
    }
    
    func writePhotoDataToTemporaryDirectory(photo: UIImage) -> URL? {
        
        
        let fixedPhoto = photo.fixOrientation()
        let photoData = UIImagePNGRepresentation(fixedPhoto)
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        
    
        try? photoData?.write(to: fileURL, options: [.atomic])
        
        
        return fileURL
    }
    
    fileprivate var temporaryPhotoURL: URL {

        // Must write to temporary directory to be able to pass image file path url to CKAsset

        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")

        try? photoData?.write(to: fileURL, options: [.atomic])

        return fileURL
    }

}

extension CKRecord {
    convenience init(_ collection: Collection) {
        
        let recordID = collection.ckrecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: Collection.collectionTypeKey, recordID: recordID)
        
        self.setValue(collection.text, forKey: Collection.textKey)
        self.setValue(collection.collectionName, forKey: collection.collectionNameKey)
        guard let owner = collection.owner,
            let ownerRecordId = owner.cloudKitRecordID else { return }
        self[collection.ownerRefrenceKey] = CKReference(recordID: ownerRecordId, action: .deleteSelf)
        
        var assets: [CKAsset] = []
        
        for photo in collection.photoArray {
            guard let url = collection.writePhotoDataToTemporaryDirectory(photo: photo) else { continue }
            
            let asset = CKAsset(fileURL: url)
            
            assets.append(asset)
        }
        self[Collection.photoArrayKey] = assets as CKRecordValue
        
        self[collection.photoDataKey] = CKAsset(fileURL: collection.temporaryPhotoURL)
    }
}

extension Collection: Equatable {
   static func ==(lhs: Collection, rhs: Collection) -> Bool {
        return lhs.collectionName == rhs.collectionName && lhs.ownerRefrence == rhs.ownerRefrence && lhs.photoData == rhs.photoData && lhs.ckrecordID == rhs.ckrecordID && lhs.owner == rhs.owner
    }
}
 


// Fetch the current user from CK

// Fetch all of the collections attached to your user (by making a predicate from the current user's reference)

// Fetch all of the users that are a part of the collections you just fetched


 extension DispatchQueue {
    static var dataWritingQueue: DispatchQueue = {
        let dataWritingQueue = DispatchQueue(label: "dataWritingQueue")

        return dataWritingQueue
    }()
 }



