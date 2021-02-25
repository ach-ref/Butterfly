//
//  UIView+Shake.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import UIKit

extension UIView {
    
    /// Horizontally shake a view.
    func shake() {
        // remove animation if exists
        layer.removeAnimation(forKey: "shake")
        // add
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values = [-30, 30, -20, 20, -10, 10, -5, 5, 0]
        animation.isAdditive = true
        animation.duration = 0.6
        layer.add(animation, forKey: "shake")
    }
}
