//
//  UITextField+Extensions.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import UIKit

extension UITextField {
  func addBottomBorder(withWidth width: CGFloat = 1) {
    let bottomLayer = CALayer()
    bottomLayer.borderColor = UIColor.lightGray.cgColor
    bottomLayer.frame = CGRect(x: 0, y: frame.size.height - width, width: frame.size.width, height: frame.size.height)
    bottomLayer.borderWidth = width
        
    layer.addSublayer(bottomLayer)
    layer.masksToBounds = true
  }
}
