//
//  MediaPickerProtocol.swift
//  StfalconContentPicker
//
//  Created by Vitalii Vasylyda on 11/21/18.
//  Copyright © 2018 Stfalcon. All rights reserved.
//

import Foundation
import UIKit
import Photos

public protocol TextInputProtocol: class {
    var inputView: UIView? { get set }
    func showInput()
}

public extension TextInputProtocol where Self: UIView {
    func showInput() {
        self.becomeFirstResponder()
    }
}

extension UITextView: TextInputProtocol {}
extension UITextField: TextInputProtocol {}

public protocol MediaPickerProtocol: class {
    var mediaPickerHeight: CGFloat { get }
    var mediaPickerEventTypeCallback: ((CollectionAssetActionsType) -> ())? { get set }

    func showMediaPickerWithInputView<T: TextInputProtocol>(view: T)
    func getCollectionAssetView() -> CollectionAssetView
    func showMediaPickerInView(_ view: UIView)
    func configureMediaPickerOptions(collectionViewHeight: CGFloat) -> MediaPickerOptions
}

public extension MediaPickerProtocol where Self: UIViewController {
    var mediaPickerHeight: CGFloat {
        return 200
    }
    
    func showMediaPickerWithInputView<T: TextInputProtocol>(view: T) {
        let options = configureMediaPickerOptions(collectionViewHeight: mediaPickerHeight)
        
        view.inputView = getMediaPickerWith(options)
        view.showInput()
    }
    
    func showMediaPickerInView(_ view: UIView) {
        let options = configureMediaPickerOptions(collectionViewHeight: mediaPickerHeight)
        
        let mediaPicker = getMediaPickerWith(options)
        view.addConstraintedSubiew(mediaPicker, with: UIEdgeInsets.zero)
    }
    
    func getMediaPickerWith(_ options: MediaPickerOptions?) -> UIView {
        var pickerOptions = MediaPickerOptions()
        
        if let options = options {
            pickerOptions = options
        }

        let inputView = getCollectionAssetView()
        inputView.options = pickerOptions
        
        inputView.actionTypeCallback = mediaPickerEventTypeCallback
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: pickerOptions.collectionViewHeight + pickerOptions.selectedItemsContainerView))
        containerView.addConstraintedSubiew(inputView)
        
        return containerView
    }
    
    func configureMediaPickerOptions(collectionViewHeight: CGFloat) -> MediaPickerOptions {
        var mediaPickerOptions = MediaPickerOptions()
        
        // ui
        mediaPickerOptions.cellWidth = collectionViewHeight / 2.0 - 0.5 // 0.5 - minimumInteritemSpacing
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

