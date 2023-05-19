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
  func save(_ data: Data, withKey key: String, withServiceName service: String?) throws
  func get(_ key: String) throws -> Data
  func removeValue(for key: String) throws
  func getAll(withServiceName service: String?) throws -> [Data]
  func clear(withServiceName service: String?) throws
}

///:nodoc:
public class SecureStorage {
  
  private let keychain: KeychainProtocol
  private let keychainQuery: KeychainQueryProtocol

  public convenience init(accessGroup: String?) {
    self.init(
      keychain: Keychain(accessGroup: accessGroup),
      keychainQuery: KeychainQuery(accessGroup: accessGroup)
    )
  }

  init(
    keychain: KeychainProtocol,
    keychainQuery: KeychainQueryProtocol
  ) {
    self.keychain = keychain
    self.keychainQuery = keychainQuery
  }
}

extension SecureStorage: SecureStorageProvider {
  public func save(_ data: Data, withKey key: String, withServiceName service: String?) throws {
    Logger.shared.log(withLevel: .info, message: "Saving \(key)")
    let deleteQuery = keychainQuery.delete(withKey: key)
    keychain.deleteItem(withQuery: deleteQuery)
    let query = keychainQuery.save(data: data, withKey: key, withServiceName: service)
    let status = keychain.addItem(withQuery: query)
    guard status == errSecSuccess else {
      let error: SecureStorageError = .invalidStatusCode(code: Int(status))
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
  
  public func getAll(withServiceName service: String?) throws -> [Data] {
    Logger.shared.log(withLevel: .info, message: "Getting all values")
    let query = keychainQuery.getAll(withServiceName: service)
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
      if case .invalidStatusCode(let code) = (error as? KeychainError),
          case code = Int(errSecItemNotFound) {
        return []
      }
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
      let error: SecureStorageError = .invalidStatusCode(code: Int(status))
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }
  
  public func clear(withServiceName service: String?) throws {
    Logger.shared.log(withLevel: .info, message: "Clearing storage")
    if try !getAll(withServiceName: service).isEmpty {
      let query = keychainQuery.deleteItems(withServiceName: service)
      let status = keychain.deleteItem(withQuery: query)
      guard status == errSecSuccess else {
        let error: SecureStorageError = .invalidStatusCode(code: Int(status))
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        throw error
      }
    }
  }
}
