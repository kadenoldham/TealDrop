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

class ImageCollectionViewController: ShiftableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCollectionViewCellDelegate {
    
    var longPressRecognizer: UILongPressGestureRecognizer?
    
    @IBOutlet weak var imageCollectionViewTitle: UINavigationItem!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    @IBAction func addPhotoButtonTapepd(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
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
    
    var isFullScreen = false
    var tappedCell: ImageCollectionViewCell?
    var darkBackgroundView: UIView!
    var originalContentMode = UIViewContentMode.scaleAspectFit
    var originalFrame = CGRect.zero
    
    @discardableResult func flipImage(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            return image
        }
        let flippedImage = UIImage(cgImage: cgImage,
                                   scale: image.scale,
                                   orientation: .leftMirrored)
        return flippedImage
    }
    

    func expandImageViewIn(cell: ImageCollectionViewCell) {
        
        guard let imageView = cell.imageViewCell else { return }
        
        if !isFullScreen {
            
            self.tappedCell = cell
            
            originalFrame = self.view.convert(imageView.frame, from: imageView.superview)
            originalContentMode = imageView.contentMode
            
            let expandingImageView = UIImageView(image: imageView.image)
            expandingImageView.contentMode = .scaleAspectFit
            
            
            expandingImageView.frame = originalFrame
            expandingImageView.isUserInteractionEnabled = true
            expandingImageView.clipsToBounds = true
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                self.view.addSubview(expandingImageView)
                cell.imageViewCell.image = UIImage()
                
                expandingImageView.frame = self.view.bounds
                
                
                
            }, completion: { (_) in
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImageView(sender:)))
                expandingImageView.addGestureRecognizer(tap)
                tap.delegate = self
                self.tapGestureRecognizer = tap
                
                guard let image = expandingImageView.image else { return }
                
                let width = self.view.frame.width
                
                let newImageViewheight = (width * ((image.size.height) / (image.size.width)))
                
                expandingImageView.frame.size.height = newImageViewheight
                expandingImageView.center = self.view.center
                
                
                self.isFullScreen = true
            })
        }
    }
    
    // MARK - Delegate
    func didSelectImage(_ sender: ImageCollectionViewCell) {
        
    }
    
    @objc func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        
        if gestureReconizer.state == .began {
            
            
            let p = gestureReconizer.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: p)
            
            if let index = indexPath,
                let cell = self.collectionView.cellForItem(at: index) as? ImageCollectionViewCell {
                cell.showDeleteButton()
            }
        }
    }
    
    @objc func dismissFullscreenImageView(sender: UITapGestureRecognizer) {
        guard let expandingImageView = sender.view as? UIImageView else { return }
        
        expandingImageView.contentMode = self.originalContentMode
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
            
            sender.view?.frame = self.originalFrame
            
            self.view.layoutIfNeeded()
            
        }, completion: { (_) in
            sender.view?.removeFromSuperview()
            
            self.isFullScreen = false
            
            guard let cell = self.tappedCell else { return }
            cell.imageViewCell.image = expandingImageView.image
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return }
        expandImageViewIn(cell: cell)
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Enter notes here" {
            textView.text = ""
            
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let text = textView.text else { return }
        guard let collection = collection else { return }
        CollectionController.shared.saveText(to: collection, text: text) { (collection) in
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if textView.text == "" {
            textView.text = "Enter notes here"
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        textView.text = collection?.text
        textView.delegate = self
        
        checkPermission()
        self.fetchCollectionImages()
        
        
        self.imageCollectionViewTitle.title = collection?.collectionName
        let nc = NotificationCenter.default
        
        // TODO: Add observer for the same notification (in the deleteImage function in the CollectionController) and have the selector reload the collectionView.
        
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
    
    
    func setupLongPressRecognizer(cell: ImageCollectionViewCell) {
        // Make the recognizer
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector (handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.numberOfTouchesRequired = 1
        
        cell.addGestureRecognizer(longPress)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.reloadData()
    }
    
    @objc func reloadData() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: - Delegates
    
    func fetchCollectionImages(_ picker: UIImagePickerController? = nil, didFinishPickingMediaWithInfo info: [String: Any]? = nil) {
        guard let info = info else { return }
        if let pickedimage = (info[UIImagePickerControllerOriginalImage] as? UIImage){
            var pickedimage = pickedimage
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
    
            if let pickedImage = (info[UIImagePickerControllerOriginalImage] as? UIImage){
                //            var collectionImages = CollectionController.shared.collection?.photoArray
    
                guard let collection = collection else { print("Cannot add picked IMage"); return
                }
    //            photoDelegate?.photoSelectViewControllerSelected(pickedImage)
    

                collection.photoArray.append(pickedImage)
    
    
                //            collection.photoArray = [pickedimage]///Will store three selected images in your array
                
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
                    
                    CollectionController.shared.uploadRecords(to: collection, images: collection.photoArray, completion: { (_) in
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    })
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
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let collection = collection else { print("returning 0 cells");return 0 }
        return collection.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell, let collection = collection else { print("else Statement hit"); return UICollectionViewCell() }
        
        
        let collectionImage = collection.photoArray[indexPath.row]
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        setupLongPressRecognizer(cell: cell)
        
        let image = flipImage(image: collectionImage)
        cell.image = image
        cell.collection = collection
        cell.delegate = self
        
        
        return cell
    }
    
    
}














