//
//  NibLoadable.swift
//  StfalconContentPicker
//
//  Created by Vitalii Vasylyda on 9/25/18.
//  Copyright © 2018 Stfalcon. All rights reserved.
//

import UIKit

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

typealias NibReusable = Reusable & NibLoadable

public protocol NibLoadable: class {
    static var nib: UINib { get }
}

public extension NibLoadable where Self: UIView {
    public static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self.classForCoder()))
    }
}

public extension NibLoadable where Self: UIView {
    public static func loadFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        
        print(view)
        return view
    }
}
