//
//  SettingsViewController.swift
//  TwilioVerifyDemo
//
//  Created by Alejandro Orozco Builes on 16/12/21.
//  Copyright © 2021 Twilio. All rights reserved.
//

import UIKit
import TwilioVerifySDK

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  let storage = SecureStorage()

  enum AppSetting: String, CaseIterable {
    case clearStorage
    case currentVersion

    var description: String {
      switch self {
        case .clearStorage:
          return "Clear Storage"
        case .currentVersion:
          return "Storage Version"
      }
    }

    var type: SettingType {
      switch self {
        case .clearStorage: return .bool
        case .currentVersion: return .int
      }
    }
    
    func toData(value: Any) -> Data {
      switch type {
        case .bool: return (value as! Bool).description.data(using: .utf8)!
        case .int: return withUnsafeBytes(of: (value as! Int).bigEndian) { Data($0) }
      }
    }
    
    func fromData(data: Data?) -> Any? {
      guard let data = data else {
        return nil
      }
      switch type {
        case .bool: return Bool(String(decoding: data, as: UTF8.self))
        case .int: return data.withUnsafeBytes {
            $0.load(as: Int.self).bigEndian
          }
      }
    }
  }

  enum SettingType {
    case bool
    case int
  }

  @objc func editTextSetting(sender: UIButton) {
    let setting = AppSetting.allCases[sender.tag]
    let alertController = UIAlertController(title: setting.description, message: "Edit text value", preferredStyle: .alert)

    alertController.addTextField { [weak self] textfield in
      textfield.placeholder = "Type"
      if let value = self?.settingValue(setting) as? String {
        textfield.text = value
      } else if let value = self?.settingValue(setting) as? Int {
        textfield.text = value.description
      }
    }

    alertController.addAction(.init(title: "Accept", style: .default, handler: { [weak self] _ in
      let text = alertController.textFields?.first?.text
      if setting.type == .int {
        self?.updateSetting(setting, with: Int(text ?? .init()))
      } else {
        self?.updateSetting(setting, with: text)
      }
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

  private func updateSetting(_ setting: AppSetting, with value: Any) {
    try? storage.save(setting.toData(value: value), withKey: setting.rawValue, withServiceName: "test")
    //UserDefaults.standard.setValue(value, forKey: setting.rawValue)
  }

  private func settingValue(_ setting: AppSetting) -> Any? {
    //return UserDefaults.standard.bool(forKey: setting.rawValue)
    return setting.fromData(data: try? storage.get(setting.rawValue))
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
        switchAccessory.isOn = settingValue(setting) as? Bool ?? false
        switchAccessory.tag = indexPath.row
        switchAccessory.addTarget(self, action: #selector(didChangeSetting(sender:)), for: .touchUpInside)
      case .int:
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
