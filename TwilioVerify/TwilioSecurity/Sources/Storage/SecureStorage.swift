//
//  SecureStorage.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
    let query = keychainQuery.save(data: data, withKey: key)
    let status = keychain.addItem(withQuery: query)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      throw error
    }
  }
  
  public func get(_ key: String) throws -> Data {
    let query = keychainQuery.getData(withKey: key)
    do {
      let result = try keychain.copyItemMatching(query: query)
      // swiftlint:disable:next force_cast
      return result as! Data
    } catch {
      throw error
    }
  }
  
  public func getAll() throws -> [Data] {
    let query = keychainQuery.getAll()
    do {
      let result = try keychain.copyItemMatching(query: query)
      guard let resultArray = result as? [Any] else {
        return []
      }
      let objectsData = resultArray.map {
        (($0 as? [String: Any])?[kSecValueData as String]) as? Data
      }.compactMap { $0 }
      return objectsData
    } catch {
      if (error as NSError).code == Int(errSecItemNotFound) {
        return []
      }
      throw error
    }
  }
  
  public func removeValue(for key: String) throws {
    let query = keychainQuery.delete(withKey: key)
    let status = keychain.deleteItem(withQuery: query)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      throw error
    }
  }
  
  public func clear() throws {
    if try !getAll().isEmpty {
      let query = keychainQuery.deleteItems()
      let status = keychain.deleteItem(withQuery: query)
      guard status == errSecSuccess else {
        let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        throw error
      }
    }
  }
}
