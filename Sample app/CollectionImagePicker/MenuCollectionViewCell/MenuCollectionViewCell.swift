//
//  MenuCollectionViewCell.swift
//  CollectionImagePicker
//
//  Created by Vitalii Vasylyda on 11/23/18.
//  Copyright © 2018 stFalcon. All rights reserved.
//

import UIKit

final class MenuCollectionViewCell: UICollectionViewCell {
    static let nib = UINib(nibName: "MenuCollectionViewCell", bundle: nil)
    static let reuseIdentifier = "MenuCollectionViewCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    
    var didTapOnButtonAction: (() -> ())?
    
    // MARK: - Public methods
    
    func configureWith(_ title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }

    // MARK: - Actions
    
    @IBAction private func showScreenAction(_ sender: UIButton) {
        didTapOnButtonAction?()
    }
}
