//
//  Alertable.swift
//  StfalconContentPicker
//
//  Created by Vitalii Vasylyda on 18.09.18.
//  Copyright © 2018 Stfalcon. All rights reserved.
//

import Foundation
import UIKit

public protocol Alertable {
    func displayMessage(_ title: String, msg: String?, actions: UIAlertAction?..., handler: ((UIAlertAction) -> ())?)
    func displayError(_ error: Error)
    func displaySheet(_ title: String?, msg: String?, actions: UIAlertAction..., cancelActionHandler: ((UIAlertAction) -> ())?)
}

public extension Alertable where Self: UIViewController {
    
    func displayError(_ error: Error) {
        displayMessage("Error", msg: error.localizedDescription, actions: nil, handler: nil)
    }
    
    func displayMessage(_ title: String, msg: String?, actions: UIAlertAction?..., handler: ((UIAlertAction) -> ())?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        if actions.isEmpty {
            let dismissAction = UIAlertAction(title: "OK", style: .default, handler: handler)
            alertController.addAction(dismissAction)
        } else {
            for action in actions {
                guard let act = action else { return }
                alertController.addAction(act)
            }
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func displaySheet(_ title: String?, msg: String?, actions: UIAlertAction..., cancelActionHandler: ((UIAlertAction) -> ())?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .actionSheet)
        alertController.view.tintColor = .black
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelActionHandler)
        
        cancelAction.setValue(UIColor.blue, forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        for action in actions { alertController.addAction(action) }
        present(alertController, animated: true, completion: nil)
    }

}
