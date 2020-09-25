//
//  FactorTableViewCell.swift
//  TwilioVerifyDemo
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import UIKit
import TwilioVerify

class FactorTableViewCell: UITableViewCell {
  
  static let reuseIdentifier = String(describing: FactorTableViewCell.self)
  
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var sidLabel: UILabel!
  @IBOutlet private weak var identityLabel: UILabel!
  @IBOutlet private weak var statusLabel: UILabel!
  
  func configure(with factor: Factor) {
    nameLabel.text = factor.friendlyName
    sidLabel.text = factor.sid
    identityLabel.text = factor.identity
    statusLabel.text = factor.status.rawValue
  }
}
