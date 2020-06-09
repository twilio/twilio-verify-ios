//
//  Storage.swift
//  TwilioVerify
//
//  Created by Santiago Avila on 6/9/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import TwilioSecurity

protocol StorageProvider {
  func save(_ data: Data, withKey key: String) throws
  func get(_ key: String) throws -> Data?
  func removeValue(for key: String) throws
}

class Storage {
  
  private let secureStorage: SecureStorageProvider
  
  init(secureStorage: SecureStorageProvider = SecureStorage()) {
    self.secureStorage = secureStorage
  }
}

extension Storage: StorageProvider {
  func save(_ data: Data, withKey key: String) throws {
    try secureStorage.save(data, withKey: key)
  }
  
  func get(_ key: String) throws -> Data? {
    do {
      return try secureStorage.get(key)
    } catch {
      throw error
    }
  }
  
  func removeValue(for key: String) throws {
    try secureStorage.removeValue(for: key)
  }
}
