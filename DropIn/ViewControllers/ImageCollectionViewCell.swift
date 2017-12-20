//
//  ImageCollectionViewCell.swift
//  DropIn
//
//  Created by Kaden Oldham on 12/13/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var imageViewCell: UIImageView!
    
    var image: UIImage? {
        didSet {
            updateViews()
        }
    }
    weak var delegate: ImageCollectionViewCellDelegate?
    
    
    override func prepareForReuse() {
        deleteButton.isHidden = true
    }
    
    weak var collection: Collection?
    
    func updateViews() {
        self.imageViewCell.image = image
    }
    
    @IBAction func deleteSelectedImage(_ sender: Any) {
        guard let image = self.image,
            let collection = self.collection else { return }
        
        CollectionController.shared.deleteImage(image: image, fromCollection: collection)
    }
    func showDeleteButton() {
        
        deleteButton.isHidden = false
    }
}

protocol ImageCollectionViewCellDelegate: class {
    func didSelectImage(_ sender: ImageCollectionViewCell)
}



