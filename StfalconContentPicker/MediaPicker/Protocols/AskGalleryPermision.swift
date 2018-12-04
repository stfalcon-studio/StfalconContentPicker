//
//  AskGalleryPermision.swift
//  StfalconContentPicker
//
//  Created by Vitalii Vasylyda on 11/22/18.
//  Copyright © 2018 Stfalcon. All rights reserved.
//

import Foundation
import Photos
import UIKit

public protocol AskGalleryPermision: class {
    var allowOpenMediaPickerCallback: (() -> ())? { get set }
    
    func checkGalleryPermisions()
    func showPopUpWithGalleryPermision()
}

public extension AskGalleryPermision where Self: UIViewController, Self: Alertable {
    // default realization for controllers that conform to protocols AskGalleryPermision, Alertable
    
    func checkGalleryPermisions() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            allowOpenMediaPickerCallback?()
            
        case .denied:
            self.displayMessage("", msg: "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access.", handler: nil)
            
        case .notDetermined:
            showPopUpWithGalleryPermision()
            
        case .restricted:
            displayMessage("", msg: "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access.", handler: nil)
        }
    }
    
    func showPopUpWithGalleryPermision() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.allowOpenMediaPickerCallback?()
                    
                case .denied, .restricted:
                    self?.displayMessage("", msg: "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access.", handler: nil)
                    
                default: break
                }
            }
        }
    }
}
