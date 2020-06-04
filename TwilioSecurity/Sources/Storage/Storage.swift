//
//  Storage.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol StorageProvider {
  func save(_ data: Data, withKey key: String) throws
  func get(_ key: String) throws -> Data
}

class Storage {
  
  private let keychain: KeychainProtocol
  private let keychainQuery: KeychainQueryProtocol
  
  init(keychain: KeychainProtocol = Keychain(),
       keychainQuery: KeychainQueryProtocol = KeychainQuery()) {
    self.keychain = keychain
    self.keychainQuery = keychainQuery
  }
}

extension Storage: StorageProvider {
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
      return result as! Data
    } catch {
      throw error
    }
  }
}
