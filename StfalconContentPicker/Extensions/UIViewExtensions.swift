//
//  UIViewExtensions.swift
//  StfalconContentPicker
//
//  Created by Vitalii Vasylyda on 9/25/18.
//  Copyright © 2018 Stfalcon. All rights reserved.
//

import UIKit

@IBDesignable
extension UIView {
    
    @IBInspectable
    public var cornerRadius: CGFloat {
        set (radius) {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = radius > 0
        } get {
            return self.layer.cornerRadius
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat {
        set (borderWidth) {
            self.layer.borderWidth = borderWidth
        } get {
            return self.layer.borderWidth
        }
    }
    
    @IBInspectable
    public var borderColor:UIColor? {
        set (color) {
            self.layer.borderColor = color?.cgColor
        } get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
    }
    
    func addShadow(radius: CGFloat, opacity: CGFloat, offset: CGSize, cornerRadius: CGFloat = 0) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = Float(opacity)
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat, rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addConstraintedSubiew(_ view: UIView, with insets: UIEdgeInsets = .zero) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let params = ["view" : view]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(insets.left)-[view]-\(insets.right)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: params)
        let verticalContraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(insets.top)-[view]-\(insets.bottom)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: params)
        addConstraints(horizontalConstraints)
        addConstraints(verticalContraints)
    }
    
    func addBlurEffect(with style: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        insertSubview(blurView, at: 0)
    }
    
    func recursivelyFindViews<T>(with type: T.Type, views: inout [T]) where T: UIView {
        for subview in subviews {
            if subview is T {
                views.append(subview as! T)
            } else {
                subview.recursivelyFindViews(with: type, views: &views)
            }
        }
    }
}
