//
//  UITextField+Extensions.swift
//  TwilioVerifyDemo
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
