//
//  UITextField+Utils.swift
//  CariocaMenuDemo
//
//  Created by Hell Rocky on 8/7/19.
//  Copyright © 2019 CariocaMenu. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func rounded() {
        
        // set rounded and white border
        self.layer.cornerRadius = 25
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        
        // set placeholder to light gray
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }
}
