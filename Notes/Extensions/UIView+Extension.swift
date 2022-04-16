//
//  UIView+Extension.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit

extension UIView {
    
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(subview)
        }
    }
    
}
