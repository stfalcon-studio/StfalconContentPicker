//
//  MediaItemCollectionViewCell.swift
//  CollectionImagePicker
//
//  Created by Vitalii Vasylyda on 11/15/18.
//  Copyright © 2018 stFalcon. All rights reserved.
//

import UIKit
import Photos

open class MediaItemCollectionViewCell: UICollectionViewCell, NibReusable {
    // MARK: - IBOutlets
    
    @IBOutlet private weak var statusImageView: UIImageView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var playButton: UIButton!
   
    // MARK: - Properties
    
    public var actionCallback: (() -> ())?
    
    // MARK: - Life cycle
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        statusImageView?.image = nil
        imageView.image = nil
        playButton.isHidden = true
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        statusImageView?.layer.borderWidth = 1.0
        statusImageView?.layer.borderColor = UIColor.white.cgColor
        statusImageView?.layer.cornerRadius = 10.0
    }
    
    // MARK: - Public
    
    open func configureWith(_ image: UIImage?, statusImage: UIImage?, type: PHAssetMediaType = .image) {
        imageView.image = image
        statusImageView.image = statusImage
        
        playButton.isHidden = type == .image
    }
    
    override open var isSelected: Bool {
        didSet {
            statusImageView?.backgroundColor = isSelected ? .green : .clear
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func playButtonAction(_ sender: UIButton) {
        actionCallback?()
    }
}
