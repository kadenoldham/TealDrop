//
//  ImageCollectionViewController.swift
//  DropIn
//
//  Created by Kaden Oldham on 12/12/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import UIKit
import Photos

protocol ImageCollectionViewControllerDelegate: class {
    
    func photoSelectedCollectionViewController(_ image: UIImage)
    
}

class ImageCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageCollectionViewTitle: UINavigationItem!
    
    @IBOutlet var imageCollectionView: UICollectionView!
    
    @IBAction func addPhotoButtonTapepd(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
                
                
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK: - properties
    var image: UIImage?
    var collection: Collection?
    weak var delegate: ImageCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        checkPermission()
        self.fetchCollectionImages()
        self.imageCollectionViewTitle.title = collection?.collectionName
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(reloadData), name: CollectionController.collectionImagesChangeNotificaton, object: nil)
        
        
        if collection?.owner == nil {
            // Go fetch the owner using the reference, and attach it to the collection.
            guard let ownerReference = collection?.ownerRefrence else { return }
            CloudKitManager().fetchRecord(withID: ownerReference.recordID, completion: { (record, error) in
                guard let record = record else { return }
                
                let user = User(cloudKitRecord: record)
                
                self.collection?.owner = user
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.reloadData()
    }
    
    @objc func reloadData() {
        self.collectionView?.reloadData()
    }
    
    // MARK: - Delegates
    
    func fetchCollectionImages(_ picker: UIImagePickerController? = nil, didFinishPickingMediaWithInfo info: [String: Any]? = nil) {
        guard let info = info else { return }
        if let pickedimage = (info[UIImagePickerControllerOriginalImage] as? UIImage){
            if self.collection?.owner == nil {
                // Go fetch the owner using the reference, and attach it to the collection.
                guard let ownerReference = self.collection?.ownerRefrence else { return }
                CloudKitManager().fetchRecord(withID: ownerReference.recordID, completion: { (record, error) in
                    guard let record = record else { return }
                    
                    let user = User(cloudKitRecord: record)
                    
                    self.collection?.owner = user
                    
                    DispatchQueue.main.async {
                        self.collection?.photoArray = [pickedimage]
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedimage = (info[UIImagePickerControllerOriginalImage] as? UIImage){
            //            var collectionImages = CollectionController.shared.collection?.photoArray
            
            guard let collection = collection else { return }
            
            //            collection.photoArray = [pickedimage]///Will store three selected images in your array
            collection.photoArray.append(pickedimage)
            
            CollectionController.shared.uploadPhotos(to: collection, images: collection.photoArray as! [UIImage], completion: { (_) in
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            })
        }
        
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let collection = collection else { print("returning 0 cells");return 0 }
        return collection.photoArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell, let collection = collection else { print("else Statement hit"); return UICollectionViewCell() }
        
        
        let collectionImage = collection.photoArray[indexPath.row]
        
        cell.imageViewCell.image = collectionImage
        
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
}














