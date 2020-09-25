//
//  CreateFactorViewController.swift
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
