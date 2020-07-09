//
//  BackendListViewController.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 7/7/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import UIKit

typealias Environment = (environment: String, url: String)

class BackendListViewController: UITableViewController {

  var callback: ((String) -> ())?
  private var environments: [Environment]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    environments = [Constants.dev, Constants.stage, Constants.prod]
  }


  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    environments.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
    cell.textLabel?.text = environments[indexPath.row].environment
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let url = environments[indexPath.row].url
    dismiss(animated: true) {
      self.callback?(url)
    }
  }

}

private extension BackendListViewController {
  struct Constants {
    static let dev = (environment: "Development", url: "https://dev-verify-sample-backend.herokuapp.com/enroll")
    static let stage = (environment: "Stage", url: "https://verify-push-stage-backend.herokuapp.com/enroll")
    static let prod = (environment: "Production", url: "https://verify-push-sample-backend.herokuapp.com/enroll")
  }
}
