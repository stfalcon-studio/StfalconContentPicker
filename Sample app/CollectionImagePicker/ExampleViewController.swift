//
//  ExampleViewController.swift
//  CollectionImagePicker
//
//  Created by Vitalii Vasylyda on 11/15/18.
//  Copyright © 2018 stFalcon. All rights reserved.
//

import UIKit
import Photos
import StfalconContentPicker

// you can inheriate from MediaPickerViewController and implemented your own logic, or you can use MediaPickerViewController directly.
 final class ExampleViewController: MediaPickerViewController {

    // you can override mediaPicker Height and set own value for it.
    override var mediaPickerHeight: CGFloat {
        return 400
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func handleMediaPickerStates() {
        // in this method we are handle all states that has collection Asset view
        
        mediaPickerEventTypeCallback = { [unowned self] action in
            switch action {
            case .didDeselectedItem(let mediaAsset):
                print(mediaAsset)
                
            case .didSelectedItem(let mediaAsset):
                print(mediaAsset)
                
            case .didTapOnImage(let mediaAsset):
                print(mediaAsset)
                
            case .didTapOnVideo(let mediaAsset):
                print(mediaAsset)
                self.showVideoWith(mediaAsset.url)
                
            case .didDinishSelectedAssets(let mediaAssets):
               // returned selected assets to previous view controller.
                self.resultCallback?(mediaAssets)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func configureMediaPickerOptions(collectionViewHeight: CGFloat) -> MediaPickerOptions {
        // implemented this method if you want to change options. But it's not necessary because MediaPicker Protocol has default implementation of this method.
        
        var mediaPickerOptions = MediaPickerOptions()
        
        // ui
        mediaPickerOptions.cellWidth = collectionViewHeight / 3.0 - 0.5 // 0.5 - minimumInteritemSpacing
        mediaPickerOptions.showSelectItemsBar = true
        mediaPickerOptions.selectedItemsContainerView = 50
        mediaPickerOptions.collectionViewHeight = collectionViewHeight
        mediaPickerOptions.lineSpacing = 0.5
        mediaPickerOptions.interitemSpacing = 0.5
        
        // media manager options
        mediaPickerOptions.requestOption.isSynchronous = true
        mediaPickerOptions.requestOption.resizeMode = .fast
        mediaPickerOptions.requestOption.deliveryMode = .highQualityFormat
        
        // fetch options
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        mediaPickerOptions.fetchOptions = fetchOptions
        
        mediaPickerOptions.fetchAssetType = .bouth
        
        return mediaPickerOptions
    }
}
