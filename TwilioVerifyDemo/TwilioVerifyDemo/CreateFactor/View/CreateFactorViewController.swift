//
//  CreateFactorViewController.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 5/15/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import UIKit
import TwilioVerify

protocol CreateFactorView: class {
  func showAlert(withMessage message: String)
  func stopLoader()
  func dismiss()
}

class CreateFactorViewController: UIViewController {

  @IBOutlet private weak var identityTextField: UITextField!
  @IBOutlet private weak var enrollmentURLTextField: UITextField!
  @IBOutlet private weak var createButton: UIButton!
  @IBOutlet weak var loader: UIActivityIndicatorView!
  
  private var presenter: CreateFactorPresentable!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    presenter = CreateFactorPresenter(withView: self)
    presenter.registerForPushNotifications()
    setupUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    enrollmentURLTextField.text = presenter.enrollmentURL()
  }
  
  @IBAction func createFactor() {
    let identity = identityTextField.text
    let url = enrollmentURLTextField.text
    loader.startAnimating()
    presenter.create(withIdentity: identity, enrollmentURL: url)
  }
}

extension CreateFactorViewController: CreateFactorView {
  func showAlert(withMessage message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
    loader.stopAnimating()
  }
  
  func stopLoader() {
    loader.stopAnimating()
  }
  
  func dismiss() {
    if #available(iOS 13.0, *), let presentationController = presentationController {
      navigationController?.presentationController?.delegate?.presentationControllerDidDismiss?(presentationController)
    }
    dismiss(animated: true, completion: nil)
  }
}

private extension CreateFactorViewController {
  func setupUI() {
    identityTextField.addBottomBorder()
    enrollmentURLTextField.addBottomBorder()
  }
}
