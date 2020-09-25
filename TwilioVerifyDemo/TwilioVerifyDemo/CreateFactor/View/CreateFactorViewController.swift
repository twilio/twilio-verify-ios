//
//  CreateFactorViewController.swift
//  TwilioVerifyDemo
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import UIKit
import TwilioVerify

protocol CreateFactorView: class {
  func showAlert(withMessage message: String)
  func stopLoader()
  func dismissView()
}

class CreateFactorViewController: UIViewController {

  @IBOutlet private weak var identityTextField: UITextField!
  @IBOutlet private weak var accessTokenURLTextField: UITextField!
  @IBOutlet private weak var createButton: UIButton!
  @IBOutlet private weak var closeButton: UIBarButtonItem!
  @IBOutlet private weak var loader: UIActivityIndicatorView!
  
  private var presenter: CreateFactorPresentable?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    presenter = CreateFactorPresenter(withView: self)
    setupUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    accessTokenURLTextField.text = presenter?.accessTokenURL()
  }
  
  @IBAction func createFactor() {
    let identity = identityTextField.text
    let url = accessTokenURLTextField.text
    loader.startAnimating()
    presenter?.create(withIdentity: identity, accessTokenURL: url)
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
  
  @objc
  func dismissView() {
    if #available(iOS 13.0, *), let presentationController = presentationController {
      navigationController?.presentationController?.delegate?.presentationControllerDidDismiss?(presentationController)
    }
    dismiss(animated: true, completion: nil)
  }
}

private extension CreateFactorViewController {
  struct Constants {
    static let backendListView = "BackendListView"
    static let storyboardId = "Main"
  }
  
  func setupUI() {
    closeButton.target = self
    closeButton.action = #selector(dismissView)
    identityTextField.addBottomBorder()
    accessTokenURLTextField.addBottomBorder()
    createButton.layer.cornerRadius = 8
  }
  
  func backendListViewController() -> UIViewController {
    let storyboard = UIStoryboard(name: Constants.storyboardId, bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: Constants.backendListView)
  }
}
