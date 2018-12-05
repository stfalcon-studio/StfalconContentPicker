//
//  MediaPickerViewController.swift
//  StfalconContentPicker
//
//  Created by Vitalii Vasylyda on 10/30/18.
//  Copyright © 2018 Stfalcon. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation

open class MediaPickerViewController: UIViewController, Alertable, MediaPickerProtocol {
    public class var bundle: Bundle {
        return Bundle(for: self.classForCoder())
    }
    
    public class var nibName: String {
        return "MediaPickerViewController"
    }
    
    class func loadFromNib<T: UIViewController>() -> T {
        return T(nibName: String(describing: self), bundle:Bundle(for: self.classForCoder()))
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var contentView: UIView!
    
    // MARK: - properties
    
    var options: MediaPickerOptions = MediaPickerOptions()
    open var resultCallback: (([MediaAsset]) -> ())?
    
    // MARK: - MediaPickerProtocol
    
    public var mediaPickerEventTypeCallback: ((CollectionAssetActionsType) -> ())?
    var allowOpenMediaPickerCallback: (() -> ())?

    // you can override mediaPicker Height and set own value for it.
    open var mediaPickerHeight: CGFloat {
        return 300
    }
    
    // MARK: - life cycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        handleMediaPickerStates()
        
        // call this method and send container that will display your media picker.
        showMediaPickerInView(contentView)
    }
    
    // MARK: - Public methods
    
    open func handleMediaPickerStates() {
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
                self.resultCallback?(mediaAssets)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    open func showVideoWith(_ url: URL?) {
        guard let url = url else { return }
        
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: url)
        
        present(playerVC, animated: true) {
            playerVC.player?.play()
        }
    }
    
    // MARK: - MediaPickerProtocol methods
    
    open func configureMediaPickerOptions(collectionViewHeight: CGFloat) -> MediaPickerOptions {
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
    
    open func getCollectionAssetView() -> CollectionAssetView {
        // you can inherit from Collection Asset View and create your own class with custom UI elemenets.
        return CollectionAssetView.loadFromNib()
    }
}


