//
//  ImageCollectionViewCell.swift
//  DropIn
//
//  Created by Kaden Oldham on 12/13/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var imageViewCell: UIImageView!
    
    // MARK: - Properties
    let feedback = UIImpactFeedbackGenerator()
    weak var collection: Collection?
    weak var delegate: ImageCollectionViewCellDelegate?
    var image: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    override func prepareForReuse() {
        deleteButton.isHidden = true
    }
    
    func updateViews() {
        self.imageViewCell.image = image
    }
    
    @IBAction func deleteSelectedImage(_ sender: Any) {
        feedback.impactOccurred()
        guard let image = self.image,
            let collection = self.collection else { return }
       
        CollectionController.shared.deleteImage(image: image, fromCollection: collection)
    }
    func showDeleteButton() {
        deleteButton.isHidden = false
    }
}

// MARK: - Protocol
protocol ImageCollectionViewCellDelegate: class {
    func didSelectImage(_ sender: ImageCollectionViewCell)
}



