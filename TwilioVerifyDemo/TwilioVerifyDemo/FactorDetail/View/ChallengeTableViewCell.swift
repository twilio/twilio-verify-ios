//
//  ChallengeTableViewCell.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 7/15/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
