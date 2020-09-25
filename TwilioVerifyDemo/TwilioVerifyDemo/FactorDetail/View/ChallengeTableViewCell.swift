//
//  ChallengeTableViewCell.swift
//  TwilioVerifyDemo
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import UIKit
import TwilioVerify

class ChallengeTableViewCell: UITableViewCell {

  static let reuseIdentifier = String(describing: ChallengeTableViewCell.self)
  
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var expirationDateLabel: UILabel!
  
  func configure(with challenge: Challenge) {
    messageLabel.text = challenge.challengeDetails.message
    expirationDateLabel.text = challenge.expirationDate.verifyStringFormat()
  }
}
