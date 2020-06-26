//
//  FactorListViewController.swift
//  TwilioVerifyDemo
//
//  Created by Santiago  Avila on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import UIKit

protocol FactorListView: class {
  func reloadData()
}

class FactorListViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!
  
  private var presenter: FactorListPresentable!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    presenter = FactorListPresenter(withView: self)
    setupUI()
  }
  
  @IBAction func createFactor() {
    guard let navController = createFactorViewController() as? UINavigationController,
          let createFactorView = navController.viewControllers.first as? CreateFactorViewController else {
      return
    }
      //This is a work around, in the future this will be removed
    createFactorView.callback = { [weak self] factor in
      guard let strongSelf = self else { return }
      strongSelf.presenter.append(factor)
    }
    present(navController, animated: true, completion: nil)
  }
}

//MARK: - UITableViewDataSource
extension FactorListViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    presenter.numberOfItems()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: FactorTableViewCell.reuseIdentifier, for: indexPath) as? FactorTableViewCell else {
      return UITableViewCell()
    }
    let factor = presenter.factor(at: indexPath.row)
    cell.configure(with: factor)
    return cell
  }
}

//MARK: - UITableViewDelegate
extension FactorListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}

extension FactorListViewController: FactorListView {
  func reloadData() {
    tableView.reloadData()
  }
}

private extension FactorListViewController {
  struct Constants {
    static let createFactorView = "CreateFactorView"
    static let storyboardId = "Main"
  }
  
  func setupUI() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.register(UINib(nibName: String(describing: FactorTableViewCell.self), bundle: nil),
    forCellReuseIdentifier: FactorTableViewCell.reuseIdentifier)
  }
  
  func createFactorViewController() -> UIViewController {
    let storyboard = UIStoryboard(name: Constants.storyboardId, bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: Constants.createFactorView)
  }
}
