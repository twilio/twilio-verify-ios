//
//  StorageProvider+AccessGroup.swift
//  TwilioVerifySDK
//
//  Copyright © 2022 Twilio.
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

import Foundation

extension Storage {

  // MARK: - Constants

  enum MigrationDirection {
    case toAccessGroup, fromAccessGroup
  }

  enum Errors: Error {
    case osStatus(Int)
  }

  // MARK: - Factors

  /// Returns all the stored factors excluding parameters such as accountService or accessGroup.
  func getAllFactors(
    using factorMapper: FactorMapperProtocol,
    keychain: KeychainProtocol
  ) -> [Factor] {
    let query: Query = [
      kSecClass: kSecClassGenericPassword,
      kSecReturnAttributes: true,
      kSecReturnData: true,
      kSecMatchLimit: kSecMatchLimitAll,
      kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ]

    guard let result = try? keychain.copyItemMatching(query: query) else {
      Logger.shared.log(withLevel: .error, message: "Failed to obtain stored Factors.")
      return []
    }

    let resultArray = result as? [Any] ?? []
    
    let data = resultArray.map {
      (($0 as? [String: Any])?[kSecValueData as String]) as? Data
    }.compactMap { $0 }

    let factors = data.compactMap { item in
      return try? factorMapper.fromStorage(withData: item)
    }

    return factors
  }

  /// Update Stored Factors with an specified kSecAttrAccessGroup
  func updateFactors(
    _ factors: [Factor],
    with accessGroup: String,
    keychain: KeychainProtocol
  ) throws {
    try factors.forEach { factor in
      let query: Query = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: factor.sid,
        kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
      ]

      let attributes: CFDictionary = [
        kSecAttrAccessGroup: accessGroup
      ] as CFDictionary

      let status = keychain.updateItem(withQuery: query, attributes: attributes)

      if status == errSecSuccess {
        Logger.shared.log(withLevel: .debug, message: "AccessGroup for factor: \(factor.sid) modified successfully")
      } else {
        Logger.shared.log(withLevel: .error, message: "Unable to add accessGroup to factor: \(factor.sid) due to status: \(status)")
        throw Errors.osStatus(Int(status))
      }

      try updateKeys(for: factor, with: accessGroup, keychain: keychain)
    }
  }

  /// Update keyPairs with the specified accessGroup for a factor
  private func updateKeys(
    for factor: Factor,
    with accessGroup: String,
    keychain: KeychainProtocol
  ) throws {
    guard
      let factor = factor as? PushFactor,
      let keyPairAlias = factor.keyPairAlias,
      let template = try? ECP256SignerTemplate(withAlias: keyPairAlias, shouldExist: true)
    else {
      Logger.shared.log(withLevel: .error, message: "Unable to update keyPairs for factor: \(factor.sid)")
      return
    }

    let query: Query = [
      kSecClass: kSecClassKey,
      kSecAttrLabel: template.alias,
      kSecAttrKeyType: template.algorithm
    ]

    let attributes: CFDictionary = [
      kSecAttrAccessGroup: accessGroup
    ] as CFDictionary

    let status = keychain.updateItem(withQuery: query, attributes: attributes)

    if status == errSecSuccess {
      Logger.shared.log(withLevel: .debug, message: "Update keyPairs for factor: \(factor.sid) ")
    } else {
      Logger.shared.log(withLevel: .error, message: "Unable to add accessGroup to for keyPairs factor: \(factor.sid) due to status: \(status)")
      throw Errors.osStatus(Int(status))
    }
  }

  // MARK: - UserDefaults

  func migrate(
    key: String,
    direction: MigrationDirection,
    with accessGroup: String?
  ) {
    let userDefaults = UserDefaults.standard
    let sharedUserDefaults = UserDefaults(suiteName: accessGroup)

    switch direction {
      case .toAccessGroup:
        sharedUserDefaults?.set(userDefaults.object(forKey: key), forKey: key)
      case .fromAccessGroup:
        userDefaults.set(sharedUserDefaults?.object(forKey: key), forKey: key)
    }
  }
}
