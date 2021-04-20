//
//  SecureStorage.swift
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

///:nodoc:
public protocol SecureStorageProvider {
  func save(_ data: Data, withKey key: String) throws
  func get(_ key: String) throws -> Data
  func removeValue(for key: String) throws
  func getAll() throws -> [Data]
  func clear() throws
}

///:nodoc:
public class SecureStorage {
  
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

extension SecureStorage: SecureStorageProvider {
  public func save(_ data: Data, withKey key: String) throws {
    Logger.shared.log(withLevel: .info, message: "Saving \(key)")
    let query = keychainQuery.save(data: data, withKey: key)
    let status = keychain.addItem(withQuery: query)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
    Logger.shared.log(withLevel: .debug, message: "Saved \(key)")
  }
  
  public func get(_ key: String) throws -> Data {
    Logger.shared.log(withLevel: .info, message: "Getting \(key)")
    let query = keychainQuery.getData(withKey: key)
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
  
  public func getAll() throws -> [Data] {
    Logger.shared.log(withLevel: .info, message: "Getting all values")
    let query = keychainQuery.getAll()
    do {
      let result = try keychain.copyItemMatching(query: query)
      guard let resultArray = result as? [Any] else {
        return []
      }
      let objectsData = resultArray.map {
        (($0 as? [String: Any])?[kSecValueData as String]) as? Data
      }.compactMap { $0 }
      Logger.shared.log(withLevel: .info, message: "Return all values")
      return objectsData
    } catch {
      if (error as NSError).code == Int(errSecItemNotFound) {
        return []
      }
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
    if try !getAll().isEmpty {
      let query = keychainQuery.deleteItems()
      let status = keychain.deleteItem(withQuery: query)
      guard status == errSecSuccess else {
        let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        throw error
      }
    }
  }
}
