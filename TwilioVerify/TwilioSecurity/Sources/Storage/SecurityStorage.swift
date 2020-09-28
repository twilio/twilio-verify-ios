//
//  Storage.swift
//  TwilioSecurity
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

protocol SecurityStorageProvider {
  func save(_ data: Data, withKey key: String) throws
  func get(_ key: String) throws -> Data
  func removeValue(for key: String) throws
}

class SecurityStorage {
  
  private let keychain: KeychainProtocol
  private let keychainQuery: KeychainQueryProtocol
  
  init(keychain: KeychainProtocol = Keychain(),
       keychainQuery: KeychainQueryProtocol = KeychainQuery()) {
    self.keychain = keychain
    self.keychainQuery = keychainQuery
  }
}

extension SecurityStorage: SecurityStorageProvider {
  func save(_ data: Data, withKey key: String) throws {
    let query = keychainQuery.save(data: data, withKey: key)
    let status = keychain.addItem(withQuery: query)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      throw error
    }
  }
  
  func get(_ key: String) throws -> Data {
    let query = keychainQuery.getData(withKey: key)
    do {
      let result = try keychain.copyItemMatching(query: query)
      // swiftlint:disable:next force_cast
      return result as! Data
    } catch {
      throw error
    }
  }
  
  func removeValue(for key: String) throws {
    let query = keychainQuery.delete(withKey: key)
    let status = keychain.deleteItem(withQuery: query)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      throw error
    }
  }
}
