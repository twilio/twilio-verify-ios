//
//  ChallengeDetailViewController.swift
//  TwilioVerifyDemo
//
//  Created by Santiago  Avila on 7/8/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import UIKit
import TwilioVerify

protocol ChallengeDetailView: class {
  func updateView()
}

class ChallengeDetailViewController: UIViewController {

  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var statusLabel: UILabel!
  @IBOutlet private weak var detailsTextView: UITextView!
  @IBOutlet private weak var detailsHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var sidLabel: UILabel!
  @IBOutlet private weak var expirationDateLabel: UILabel!
  @IBOutlet private weak var updatedDateLabel: UILabel!
  @IBOutlet private weak var denyButton: UIButton!
  @IBOutlet private weak var approveButton: UIButton!
  @IBOutlet private weak var buttonsContainer: UIView!
  
  
  var presenter: ChallengeDetailPresentable!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if presenter == nil {
      presenter = ChallengeDetailPresenter(withView: self)
    }
  }
  
  
  @IBAction func updateChallenge(_ sender: UIButton) {
    presenter.updateChallenge(withStatus: sender.tag == 0 ? .denied : .approved)
  }
}

extension ChallengeDetailViewController: ChallengeDetailView {
  func updateView() {
    messageLabel.text = presenter.challenge.challengeDetails.message
    statusLabel.text = presenter.challenge.status.rawValue
    sidLabel.text = presenter.challenge.sid
    var detailText = String()
    presenter.challenge.challengeDetails.fields.forEach {
      detailText.append("\($0.label): \($0.value)\n")
    }
    detailsTextView.text = detailText
    detailsHeightConstraint.constant = detailsTextView.contentSize.height
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "MMM d yyy, h:mm a"
    expirationDateLabel.text = formatter.string(from: presenter.challenge.expirationDate)
    updatedDateLabel.text = formatter.string(from: presenter.challenge.updatedAt)
    buttonsContainer.isHidden = !(presenter.challenge.status == .pending)
    detailsTextView.layoutSubviews()
  }
}

private extension ChallengeDetailViewController {
  func setupUI() {
    denyButton.layer.cornerRadius = 8
    approveButton.layer.cornerRadius = 8
    buttonsContainer.isHidden = true
  }
}
