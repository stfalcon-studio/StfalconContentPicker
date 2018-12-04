//
//  CollectionAssetView.swift
//  StfalconContentPicker
//
//  Created by Vitalii Vasylyda on 11/20/18.
//  Copyright © 2018 Stfalcon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

public enum CollectionAssetActionsType {
    case didDinishSelectedAssets([MediaAsset])
    case didSelectedItem(MediaAsset)
    case didDeselectedItem(MediaAsset)
    case didTapOnVideo(MediaAsset)
    case didTapOnImage(MediaAsset)
}

// you can override this class and implement your own logic for each method

open class CollectionAssetView: UIView, NibLoadable {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var selectedItemsContainerView: UIView!
    @IBOutlet private weak var selectedItemsBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var showAllAssetsButton: UIButton!
    @IBOutlet private weak var showPhotosButton: UIButton!
    @IBOutlet private weak var showVideosButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var contentView: UIView!
    
    private lazy var mediaManager = MediaManager()
    private var currentFilter: Filters = .all
    
    var options: MediaPickerOptions = MediaPickerOptions() {
        didSet {
            fetchAssets()
        }
    }
    
    var actionTypeCallback: ((CollectionAssetActionsType) -> ())?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        translatesAutoresizingMaskIntoConstraints = false
        configureCollectionView()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        collectionViewHeightConstraint.constant = options.collectionViewHeight
        selectedItemsContainerView.isHidden = !options.showSelectItemsBar
        selectedItemsBarHeightConstraint.constant = options.selectedItemsContainerView
        collectionView.backgroundColor = options.collectionBackgroundColor
    }
    
    // MARK: - Actions
    
    @IBAction open func doneButtonAction(_ sender: UIButton) {
        getSelectedAssets()
    }
    
    @IBAction private func showVideosAction(_ sender: UIButton) {
        currentFilter = .videos
        startFilter()
    }
    
    @IBAction private func showPhotosAction(_ sender: UIButton) {
        currentFilter = .photos
        startFilter()
    }
    
    @IBAction private func showAllAssetsAction(_ sender: UIButton) {
        currentFilter = .all
        startFilter()
    }
    
    // MARK: - Public
    
    open func configureCollectionView() {
        collectionView.allowsMultipleSelection = true
        collectionView.register(MediaItemCollectionViewCell.nib, forCellWithReuseIdentifier: MediaItemCollectionViewCell.reuseIdentifier)
    }
}

// MARK: - Methods

public extension CollectionAssetView {
    func getSelectedAssets() {
        var selectedImages: [MediaAsset] = []
        
        if let selectedIndexes = collectionView.indexPathsForSelectedItems {
            for index in selectedIndexes {
                selectedImages.append(mediaManager.mediaAssets[index.item])
            }
        }
        
        actionTypeCallback?(.didDinishSelectedAssets(selectedImages))
    }
    
    func fetchAssets() {
        mediaManager.defaultImageRequestOptions = options.requestOption
        mediaManager.startFetchWith(options.fetchAssetType, fetchOption: options.fetchOptions, completionBlock: { [weak self] in
            self?.collectionView.reloadData()
        })
    }
    
    func startFilter() {
        mediaManager.filterBy(currentFilter) { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionAssetView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaManager.countOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaItemCollectionViewCell.reuseIdentifier, for: indexPath) as! MediaItemCollectionViewCell
        
        
        mediaManager.getAssetFor(indexPath.item, size: options.fetchSize) { mediaAsset in
            cell.configureWith(mediaAsset.preview, statusImage: nil, type: mediaAsset.type)
        }
        
        cell.actionCallback =  { [unowned self] in
            self.actionTypeCallback?(.didTapOnVideo(self.mediaManager.mediaAssets[indexPath.item]))
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionAssetView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard collectionView.indexPathsForSelectedItems?.count ?? 0 < options.maxLimitSelectedPhotos else { return false }
        
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         actionTypeCallback?(.didSelectedItem(mediaManager.mediaAssets[indexPath.item]))
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        actionTypeCallback?(.didDeselectedItem(mediaManager.mediaAssets[indexPath.item]))
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionAssetView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return options.lineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return options.interitemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: options.cellWidth, height: options.cellWidth)
    }
}


