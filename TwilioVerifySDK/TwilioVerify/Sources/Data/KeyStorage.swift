//
//  KeyStorage.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio.
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

protocol KeyStorage {
  func createKey(withAlias alias: String, allowIphoneMigration: Bool) throws -> String
  func sign(withAlias alias: String, message: String, allowIphoneMigration: Bool) throws -> Data
  func signAndEncode(withAlias alias: String, message: String, allowIphoneMigration: Bool) throws -> String
  func deleteKey(withAlias alias: String) throws
}

class KeyStorageAdapter {
  
  private let keyManager: KeyManagerProtocol
  
  init(keyManager: KeyManagerProtocol) {
    self.keyManager = keyManager
  }
}

extension KeyStorageAdapter: KeyStorage {
  func createKey(
    withAlias alias: String,
    allowIphoneMigration: Bool
  ) throws -> String {
    do {
      let template = try signerTemplate(withAlias: alias, allowIphoneMigration: allowIphoneMigration, shouldExist: false)
      let signer = try keyManager.signer(withTemplate: template)
      let publicKey = try signer.getPublic()
      return publicKey.base64EncodedString()
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }
  
  func sign(
    withAlias alias: String,
    message: String,
    allowIphoneMigration: Bool
  ) throws -> Data {
    do {
      let template = try signerTemplate(withAlias: alias, allowIphoneMigration: allowIphoneMigration)
      let signer = try keyManager.signer(withTemplate: template)
      let signature = try signer.sign(message.data(using: .utf8)!)
      return signature
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw TwilioVerifyError.keyStorageError(error: error)
    }
  }
  
  func signAndEncode(
    withAlias alias: String,
    message: String,
    allowIphoneMigration: Bool
  ) throws -> String {
    do {
      let signature = try sign(withAlias: alias, message: message, allowIphoneMigration: allowIphoneMigration)
      return signature.base64EncodedString()
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }
  
  func deleteKey(withAlias alias: String) throws {
    try keyManager.deleteKey(withAlias: alias)
  }
}

private extension KeyStorageAdapter {
  func signerTemplate(withAlias alias: String, allowIphoneMigration: Bool, shouldExist: Bool = true) throws -> SignerTemplate {
    return try ECP256SignerTemplate(withAlias: alias, shouldExist: shouldExist, allowIphoneMigration: allowIphoneMigration)
  }
}
