//
//  ChallengeDetailViewController.swift
//  TwilioVerifyDemo
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

protocol ChallengeDetailView: class {
  func updateView()
  func showAlert(withMessage message: String)
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
  @IBOutlet private weak var closeButton: UIBarButtonItem!

  var presenter: ChallengeDetailPresentable?
  var shouldShowButtonToDismissView = false
  
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
    presenter?.updateChallenge(withStatus: sender.tag == 0 ? .denied : .approved)
  }
}

extension ChallengeDetailViewController: ChallengeDetailView {
  func updateView() {
    messageLabel.text = presenter?.challenge.challengeDetails.message
    statusLabel.text = presenter?.challenge.status.rawValue
    sidLabel.text = presenter?.challenge.sid
    var detailText = String()
    presenter?.challenge.challengeDetails.fields.forEach {
      detailText.append("\($0.label): \($0.value)\n")
    }
    if let hiddenDetails = presenter?.challenge.hiddenDetails {
      detailText.append("Hidden Details\n")
      hiddenDetails.forEach {
        detailText.append("  \($0.key): \($0.value)\n")
      }
    }
    detailsTextView.text = detailText
    detailsHeightConstraint.constant = detailsTextView.contentSize.height
    expirationDateLabel.text = presenter?.challenge.expirationDate.verifyStringFormat()
    updatedDateLabel.text = presenter?.challenge.updatedAt.verifyStringFormat()
    buttonsContainer.isHidden = !(presenter?.challenge.status == .pending)
    detailsTextView.layoutSubviews()
  }
  
  func showAlert(withMessage message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}

private extension ChallengeDetailViewController {
  func setupUI() {
    closeButton.target = self
    closeButton.action = #selector(dismissView)
    denyButton.layer.cornerRadius = 8
    approveButton.layer.cornerRadius = 8
    buttonsContainer.isHidden = true
  }
  
  @objc func dismissView() {
    if shouldShowButtonToDismissView {
      dismiss(animated: true, completion: nil)
    } else {
      navigationController?.popViewController(animated: true)
    }
  }
}
