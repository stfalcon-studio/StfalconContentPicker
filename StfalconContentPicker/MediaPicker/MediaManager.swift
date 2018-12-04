//
//  MediaManager.swift
//  StfalconContentPicker
//
//  Created by Vitalii Vasylyda on 11/16/18.
//  Copyright © 2018 stFalcon. All rights reserved.
//

import UIKit
import Photos

open class MediaManager {
    
    // MARK: - Properties
    
    private let imageManager = PHImageManager()
    private(set) var assets: [PHAsset] = []
    private(set) var mediaAssets: [MediaAsset] = []
    private var allMediaAssets: [MediaAsset] = []
    private var userInteractiveQueue = DispatchQueue(label: "MediaManager - backgroundQueue", qos: .userInteractive, attributes: .concurrent)
    private(set) var countOfItems = 0
    private var isSrollToTheEnd = false
    
    var defaultImageRequestOptions = PHImageRequestOptions()
    
    // MARK: - Public methods
    
    func filterBy(_ type: Filters, completionBlock: @escaping (() -> ())) {
        mediaAssets = allMediaAssets
    
        switch type {
        case .all:
            countOfItems = assets.count
        case .photos:
            mediaAssets = mediaAssets.filter { $0.type == .image }
            countOfItems = mediaAssets.count
        case .videos:
            mediaAssets = mediaAssets.filter { $0.type == .video }
            countOfItems = mediaAssets.count
        }
        
        completionBlock()
    }
    
    func startFetchWith(_ type: FetchAssetType, fetchOption: PHFetchOptions?, completionBlock: @escaping (() -> ())) {
        let fetchResult = getFetchRequestAccordingTo(type, fetchOption: fetchOption)
        
        fetchResult.enumerateObjects({ item, _, _ in
            self.assets.append(item)
        })
        
        countOfItems = assets.count
        completionBlock()
    }
    
    func getAssetFor(_ index: Int, size: CGSize = CGSize(width: 200, height: 200), resultBlock: @escaping ((MediaAsset) -> ())) {
        if index < mediaAssets.count {
            resultBlock(mediaAssets[index])
        } else {
            getImageFor(assets[index], previewSize: size, requestOption: defaultImageRequestOptions, resultBlock: resultBlock)
        }
    }
    
    func getImageFor(_ asset: PHAsset, previewSize: CGSize = CGSize(width: 200, height: 200), requestOption: PHImageRequestOptions?, resultBlock: @escaping ((MediaAsset) -> ())) {
        let options = requestOption == nil ? defaultImageRequestOptions : requestOption
        options?.isSynchronous = false
        
        userInteractiveQueue.async(flags: .barrier) {
            self.imageManager.requestImage(for: asset, targetSize: previewSize, contentMode: .aspectFill, options: options) { [weak self] image, erorr in
                if let image = image {
                    DispatchQueue.main.async(execute: {
                        // TODO: need to change self?.mediaAssets to dict where key will bee unic identifier of asset
                        let item = MediaAsset(type: asset.mediaType ,preview: image, url: nil)
                        self?.mediaAssets.append(item)
                        self?.allMediaAssets.append(item)
                        
                        if asset.mediaType == .video {
                            self?.userInteractiveQueue.async {
                                self?.getUrlFor(asset, item: item)
                            }
                        }
                        
                        resultBlock(item)
                    })
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func getFetchRequestAccordingTo(_ type: FetchAssetType, fetchOption: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        switch type {
        case .image:
            return PHAsset.fetchAssets(with: .image, options: fetchOption)
        case .video:
            return PHAsset.fetchAssets(with: .video, options: fetchOption)
        case .bouth:
            return PHAsset.fetchAssets(with: fetchOption)
        }
    }
    
    private func getUrlFor(_ asset: PHAsset, item: MediaAsset) {
//        if item.type == .image {
//            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
//            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
//                return true
//            }
//            asset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
//                DispatchQueue.main.async {
//                    item.url = contentEditingInput?.fullSizeImageURL
//                }
//            })
//        } else if item.type == .video {
//            let options: PHVideoRequestOptions = PHVideoRequestOptions()
//            options.version = .original
//
//            imageManager.requestAVAsset(forVideo: asset, options: options, resultHandler: { (asset, _, _) in
//                guard let avAsset = asset as? AVURLAsset else { return }
//
//                DispatchQueue.main.async {
//                    item.url = avAsset.url
//                }
//            })
//        }
        
        
        
        imageManager.requestAVAsset(forVideo: asset, options: nil) { avAsset, _, _ in
            guard let assetUrl = avAsset as? AVURLAsset else { return }
            
            DispatchQueue.main.async {
                item.url = assetUrl.url
            }
        }
    }
}
