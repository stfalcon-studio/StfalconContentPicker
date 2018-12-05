//
//  ViewController.swift
//  CollectionImagePicker
//
//  Created by Vitalii Vasylyda on 11/13/18.
//  Copyright © 2018 stFalcon. All rights reserved.
//

import UIKit
import Photos
import AVKit
import StfalconContentPicker

// if you want to have default realization for get access to photo gallery, you will need to conform your controller to AskGalleryPermision, Alertable protocols. Or you can them self implemented AskGalleryPermision protocols method with your own realization.

final class MediaViewController: UIViewController, Alertable, AskGalleryPermision {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var button: UIButton!
     
    // MARK: - Properties
    
    private var cellWidth: CGFloat = 100 // default size
    private var dataSource: [MediaAsset] = []
    
    // MARK: - AskGalleryPermision
    
    var allowOpenMediaPickerCallback: (() -> ())?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        handleAccessToGallery()
    }
    
    // MARK: - Actions
    
    @IBAction private func button(_ sender: UIButton) {
        checkGalleryPermisions()
    }
    
    @IBAction private func dismissAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private methods

private extension MediaViewController {
    func handleAccessToGallery() {
        // will call this callback when user has right for open gallery.
        allowOpenMediaPickerCallback = { [weak self] in
            self?.showMediaPicker()
        }
    }
    
    func configureUI() {
        collectionView.register(MediaItemCollectionViewCell.nib, forCellWithReuseIdentifier: MediaItemCollectionViewCell.reuseIdentifier)
        cellWidth = (UIScreen.main.bounds.width / 3.0) - 0.5 // 0.5 - minimumInteritemSpacing
    }
    
    func showMediaPicker() {
        let controller = ExampleViewController.init(nibName: MediaPickerViewController.nibName, bundle: Bundle(for: MediaPickerViewController().classForCoder))
 
        // handle callback with selected assets.
        controller.resultCallback = { [unowned self] images in
            self.dataSource = images
            self.collectionView.reloadData()
        }

        controller.modalPresentationStyle = .overFullScreen
        controller.view.backgroundColor = .clear
        
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension MediaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaItemCollectionViewCell.reuseIdentifier, for: indexPath) as! MediaItemCollectionViewCell
        
        cell.configureWith(dataSource[indexPath.item].preview, statusImage: nil)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MediaViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
