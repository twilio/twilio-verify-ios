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
import TwilioVerifySDK

protocol ChallengeDetailView: AnyObject {
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

  private var numberSelectionContainer: UIView?

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
    updateButtonsVisibility()
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

  func updateButtonsVisibility() {
    numberSelectionContainer?.removeFromSuperview()
    numberSelectionContainer = nil

    guard presenter?.challenge.status == .pending else {
      buttonsContainer.isHidden = true
      return
    }

    if let hiddenDetails = presenter?.challenge.hiddenDetails,
       let selectedNumber = hiddenDetails["selectedNumber"],
       let rndNumber1 = hiddenDetails["rndNumber1"],
       let rndNumber2 = hiddenDetails["rndNumber2"],
       !selectedNumber.isEmpty, !rndNumber1.isEmpty, !rndNumber2.isEmpty {
      buttonsContainer.isHidden = true
      showNumberSelectionUI(selectedNumber: selectedNumber, numbers: [selectedNumber, rndNumber1, rndNumber2])
    } else {
      buttonsContainer.isHidden = false
    }
  }

  func showNumberSelectionUI(selectedNumber: String, numbers: [String]) {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(container)

    let numbersStack = UIStackView()
    numbersStack.axis = .horizontal
    numbersStack.distribution = .equalSpacing
    numbersStack.alignment = .center
    numbersStack.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(numbersStack)

    for number in numbers.shuffled() {
      let btn = makeNumberCircleButton(title: number)
      if number == selectedNumber {
        btn.addTarget(self, action: #selector(numberApproved), for: .touchUpInside)
      } else {
        btn.addTarget(self, action: #selector(numberDenied), for: .touchUpInside)
      }
      btn.addTarget(self, action: #selector(numberButtonTouchDown(_:)), for: .touchDown)
      btn.addTarget(self, action: #selector(numberButtonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
      numbersStack.addArrangedSubview(btn)
    }

    let declineBtn = UIButton(type: .custom)
    declineBtn.translatesAutoresizingMaskIntoConstraints = false
    declineBtn.setTitle("DECLINE", for: .normal)
    declineBtn.backgroundColor = UIColor(red: 0.824, green: 0.133, blue: 0.176, alpha: 1)
    declineBtn.setTitleColor(.white, for: .normal)
    declineBtn.titleLabel?.font = .boldSystemFont(ofSize: 18)
    declineBtn.layer.cornerRadius = 8
    declineBtn.addTarget(self, action: #selector(numberDenied), for: .touchUpInside)
    container.addSubview(declineBtn)

    NSLayoutConstraint.activate([
      numbersStack.topAnchor.constraint(equalTo: container.topAnchor),
      numbersStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
      numbersStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
      numbersStack.heightAnchor.constraint(equalToConstant: 80),

      declineBtn.topAnchor.constraint(equalTo: numbersStack.bottomAnchor, constant: 16),
      declineBtn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      declineBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      declineBtn.heightAnchor.constraint(equalToConstant: 40),
      declineBtn.bottomAnchor.constraint(equalTo: container.bottomAnchor),

      container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48)
    ])

    numberSelectionContainer = container
  }

  func makeNumberCircleButton(title: String) -> UIButton {
    let btn = UIButton(type: .custom)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitle(title, for: .normal)
    btn.backgroundColor = UIColor(red: 0.137, green: 0.533, blue: 0.137, alpha: 1)
    btn.setTitleColor(.white, for: .normal)
    btn.titleLabel?.font = .boldSystemFont(ofSize: 22)
    btn.layer.cornerRadius = 40
    btn.clipsToBounds = true
    NSLayoutConstraint.activate([
      btn.widthAnchor.constraint(equalToConstant: 80),
      btn.heightAnchor.constraint(equalToConstant: 80)
    ])
    return btn
  }

  @objc func numberButtonTouchDown(_ sender: UIButton) {
    UIView.animate(withDuration: 0.1) { sender.alpha = 0.5 }
  }

  @objc func numberButtonTouchUp(_ sender: UIButton) {
    UIView.animate(withDuration: 0.1) { sender.alpha = 1.0 }
  }

  @objc func numberApproved() {
    presenter?.updateChallenge(withStatus: .approved)
  }

  @objc func numberDenied() {
    presenter?.updateChallenge(withStatus: .denied)
  }

  @objc func dismissView() {
    if shouldShowButtonToDismissView {
      dismiss(animated: true, completion: nil)
    } else {
      navigationController?.popViewController(animated: true)
    }
  }
}
