//
//  FactorDetailViewController.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 7/15/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import UIKit

protocol FactorDetailView: class {
  func showAlert(withMessage message: String)
  func updateFactorView()
  func updateChallengesList()
}

class FactorDetailViewController: UIViewController {
  
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var identityLabel: UILabel!
  @IBOutlet private weak var statusLabel: UILabel!
  @IBOutlet private weak var sidTextField: UITextField!
  @IBOutlet private weak var tableView: UITableView!
  
  var presenter: FactorDetailPresentable!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presenter.didAppear()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let challengeDetailView = segue.destination as? ChallengeDetailViewController,
          let index = sender as? Int else {
      return
    }
    let challenge = presenter.challenge(at: index)
    
    challengeDetailView.presenter = ChallengeDetailPresenter(withView: challengeDetailView, challengeSid: challenge.sid, factorSid: presenter.factor.sid)
  }
}

// MARK: - UITableViewDataSource
extension FactorDetailViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    presenter.numberOfItems()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ChallengeTableViewCell.reuseIdentifier, for: indexPath) as? ChallengeTableViewCell else {
      return UITableViewCell()
    }
    let challenge = presenter.challenge(at: indexPath.row)
    cell.configure(with: challenge)
    return cell
  }
}

// MARK: - UITableViewDelegate
extension FactorDetailViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: Constants.challengeDetailSegueId, sender: indexPath.row)
  }
}

extension FactorDetailViewController: FactorDetailView {
  func updateFactorView() {
    nameLabel.text = presenter.factor.friendlyName
    sidTextField.text = presenter.factor.sid
    identityLabel.text = presenter.factor.identity
    statusLabel.text = presenter.factor.status.rawValue
    title = presenter.factor.friendlyName
  }
  
  func updateChallengesList() {
    tableView.reloadData()
  }
  
  func showAlert(withMessage message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}

private extension FactorDetailViewController {
  struct Constants {
    static let challengeDetailSegueId = "ChallengeDetail"
  }
  func setup() {
    sidTextField.inputView = UIView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.register(UINib(nibName: String(describing: ChallengeTableViewCell.self), bundle: nil), forCellReuseIdentifier: ChallengeTableViewCell.reuseIdentifier)
  }
}
