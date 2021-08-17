//
//  AuthenticatedSecureStorage.swift
//  TwilioSecurity
//
//  Copyright © 2021 Twilio.
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
import LocalAuthentication

///:nodoc:
public protocol AuthenticatedSecureStorageProvider {
  func save(_ data: Data, withKey key: String) throws
  func get(_ key: String, authenticationPrompt: String) throws -> Data
  func removeValue(for key: String) throws
  func clear() throws
}

///:nodoc:
public class AuthenticatedSecureStorage {

  private let keychain: KeychainProtocol
  private let keychainQuery: KeychainQueryProtocol

  public convenience init() {
    self.init(keychain: Keychain(), keychainQuery: KeychainQuery())
  }

  init(keychain: KeychainProtocol = Keychain(),
    keychainQuery: KeychainQueryProtocol = KeychainQuery()) {
    self.keychain = keychain
    self.keychainQuery = keychainQuery
  }
}

extension AuthenticatedSecureStorage: AuthenticatedSecureStorageProvider {
  public func save(_ data: Data, withKey key: String) throws {
    Logger.shared.log(withLevel: .info, message: "Saving \(key)")
    let accessControl = try getAccessControl()
    let context = LAContext()
    let query = keychainQuery.save(data: data, withKey: key, accessControl: accessControl, context: context)
    let status = keychain.addItem(withQuery: query)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
    Logger.shared.log(withLevel: .debug, message: "Saved \(key)")
  }

  public func get(_ key: String, authenticationPrompt: String) throws -> Data {
    Logger.shared.log(withLevel: .info, message: "Getting \(key)")
    let query = keychainQuery.getData(withKey: key, authenticationPrompt: authenticationPrompt)
    do {
      let result = try keychain.copyItemMatching(query: query)
      // swiftlint:disable:next force_cast
      let data = result as! Data
      Logger.shared.log(withLevel: .debug, message: "Return value for \(key)")
      return data
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }

  public func removeValue(for key: String) throws {
    Logger.shared.log(withLevel: .info, message: "Removing \(key)")
    let query = keychainQuery.delete(withKey: key)
    let status = keychain.deleteItem(withQuery: query)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }

  public func clear() throws {
    Logger.shared.log(withLevel: .info, message: "Clearing storage")
    let query = keychainQuery.deleteItems()
    let status = keychain.deleteItem(withQuery: query)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }

  private func getAccessControl() throws -> SecAccessControl {
    if #available(iOS 11.3, *) {
      return try keychain.accessControl(withProtection: Constants.accessControlProtection, flags: Constants.accessControlFlagsBiometrics)
    } else {
      return try keychain.accessControl(withProtection: Constants.accessControlProtection, flags: Constants.accessControlFlags)
    }
  }

  struct Constants {
    static let accessControlProtection = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
    @available(iOS 11.3, *)
    static let accessControlFlagsBiometrics: SecAccessControlCreateFlags = .biometryCurrentSet
    static let accessControlFlags: SecAccessControlCreateFlags = .touchIDCurrentSet
  }
}
