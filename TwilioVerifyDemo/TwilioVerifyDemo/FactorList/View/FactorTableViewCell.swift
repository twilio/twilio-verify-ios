//
//  FactorTableViewCell.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import UIKit
import TwilioVerify

class FactorTableViewCell: UITableViewCell {
  
  static let reuseIdentifier = String(describing: FactorTableViewCell.self)
  
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var sidLabel: UILabel!
  @IBOutlet private weak var entityLabel: UILabel!
  @IBOutlet private weak var statusLabel: UILabel!
  
  func configure(with factor: Factor) {
    nameLabel.text = factor.friendlyName
    sidLabel.text = factor.sid
    entityLabel.text = factor.entityIdentity
    statusLabel.text = factor.status.rawValue
  }
}
