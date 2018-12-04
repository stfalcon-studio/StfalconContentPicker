//
//  MediaAsset.swift
//  StfalconContentPicker
//
//  Created by Vitalii Vasylyda on 11/16/18.
//  Copyright © 2018 Stfalcon. All rights reserved.
//

import UIKit
import Photos

public enum FetchAssetType: Int {
    case image
    case video
    case bouth
}

public enum Filters: Int {
    case photos
    case videos
    case all
}

public struct MediaPickerOptions {
    // ui
    public var collectionViewHeight: CGFloat = 150.0
    public var cellWidth: CGFloat = 50 // default size
    public var interitemSpacing: CGFloat = 0.5
    public var lineSpacing: CGFloat = 0.5
    public var showSelectItemsBar: Bool = false
    public var selectedItemsContainerView: CGFloat = 50.0
    public var collectionBackgroundColor: UIColor = .white
    
    // media manager options
    public var fetchSize: CGSize = CGSize(width: 250, height: 250)
    public var maxLimitSelectedPhotos = 20
    public var fetchAssetsLimit = 10
    public var fetchAssetType: FetchAssetType = .bouth
    public var fetchOptions: PHFetchOptions?
    public var requestOption = PHImageRequestOptions()
    
    public init() { }
}

public protocol MediaAssetProtocol {
    var type: PHAssetMediaType { get set }
    var preview: UIImage? { get set }
    var url: URL? { get set }
}

open class MediaAsset: MediaAssetProtocol, Hashable {
    // Hashable
    
    public static func == (lhs: MediaAsset, rhs: MediaAsset) -> Bool {
        return lhs.type == rhs.type && lhs.preview == rhs.preview
    }
    
    public var hashValue: Int {
        return abs(Data().hashValue)
    }
    
    // Propertries
    public var type: PHAssetMediaType = .image
    public var preview: UIImage?
    public var url: URL?
    
    
    init(type: PHAssetMediaType = .image, preview: UIImage?, url: URL?) {
        self.type = type
        self.preview = preview
        self.url = url
    }
}
