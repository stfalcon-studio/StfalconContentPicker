//
//  MockDescription.swift
//  CollectionImagePicker
//
//  Created by Vitalii Vasylyda on 11/23/18.
//  Copyright © 2018 stFalcon. All rights reserved.
//

import Foundation

final class ProjectDescription {
    var title = ""
    var descriptionString = ""
}

final class MockDescription {
    func getMockData() -> [ProjectDescription] {
        let projectDescription = ProjectDescription()
        projectDescription.title = "Present modally in controller"
        projectDescription.descriptionString = "In this example, you can see how to use content picker when it belong to view controller. You can create your own custom view controller or use MediaPickerViewController class directly"
        
        let projectDescription1 = ProjectDescription()
        projectDescription1.title = "Show like input view in UITextView"
        projectDescription1.descriptionString = "In this example with chat you can see how to use content picker when it belongs to input view in UITextView, also you can put it to UITextField. Open conversation screen and touch on attach button on message input bar"
        
        return [projectDescription, projectDescription1]
    }
}
