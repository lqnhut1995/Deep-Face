//
//  UIButton+Utils.swift
//  CariocaMenuDemo
//
//  Created by Hell Rocky on 8/7/19.
//  Copyright © 2019 CariocaMenu. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func rounded() {
        
        // set rounded and white border
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
    }
}
