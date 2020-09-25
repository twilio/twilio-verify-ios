//
//  ChallengeTableViewCell.swift
//  TwilioVerifyDemo
//
//  Copyright © 2020 Twilio.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
