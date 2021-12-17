//
//  SettingsViewController.swift
//  TwilioVerifyDemo
//
//  Created by Alejandro Orozco Builes on 16/12/21.
//  Copyright © 2021 Twilio. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  enum AppSetting: String, CaseIterable {
    case clearStorage
    case storageVersion

    var description: String {
      switch self {
        case .clearStorage:
          return "Clear Storage"
        case .storageVersion:
          return "Storage Version"
      }
    }

    var type: SettingType {
      switch self {
        case .clearStorage:
          return .bool
        case .storageVersion:
          return .text
      }
    }
  }

  enum SettingType {
    case bool
    case text
  }

  @objc func editTextSetting(sender: UIButton) {
    let setting = AppSetting.allCases[sender.tag]
    let alertController = UIAlertController(title: setting.description, message: "Edit text value", preferredStyle: .alert)

    alertController.addTextField { [weak self] textfield in
      textfield.placeholder = "Type"
      textfield.text = self?.settingValue(setting)
    }

    alertController.addAction(.init(title: "Accept", style: .default, handler: { [weak self] _ in
      let text = alertController.textFields?.first?.text
      self?.updateSetting(setting, with: text)
      alertController.dismiss(animated: true)
    }))

    alertController.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
      alertController.dismiss(animated: true)
    }))

    present(alertController, animated: true)
  }

  @objc func didChangeSetting(sender: UISwitch) {
    let setting = AppSetting.allCases[sender.tag]
    updateSetting(setting, with: sender.isOn)
  }

  private func updateSetting(_ setting: AppSetting, with value: Bool) {
    UserDefaults.standard.setValue(value, forKey: setting.rawValue)
  }

  private func updateSetting(_ setting: AppSetting, with value: String?) {
    UserDefaults.standard.setValue(value, forKey: setting.rawValue)
  }

  private func settingValue(_ setting: AppSetting) -> Bool {
    return UserDefaults.standard.bool(forKey: setting.rawValue)
  }

  private func settingValue(_ setting: AppSetting) -> String? {
    return UserDefaults.standard.string(forKey: setting.rawValue)
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return AppSetting.allCases.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =  UITableViewCell()
    let setting = AppSetting.allCases[indexPath.row]
    cell.textLabel?.text = setting.description

    switch setting.type {
      case .bool:
        let switchAccessory = UISwitch(frame: .zero)
        cell.accessoryView = switchAccessory
        switchAccessory.isOn = settingValue(setting)
        switchAccessory.tag = indexPath.row
        switchAccessory.addTarget(self, action: #selector(didChangeSetting(sender:)), for: .touchUpInside)
      case .text:
        let button = UIButton(type: .roundedRect)
        button.tag = indexPath.row
        button.setTitle("Edit", for: .normal)
        button.addTarget(self, action: #selector(editTextSetting(sender:)), for: .touchUpInside)
        button.sizeToFit()
        cell.accessoryView = button
    }

    return cell
  }
}
