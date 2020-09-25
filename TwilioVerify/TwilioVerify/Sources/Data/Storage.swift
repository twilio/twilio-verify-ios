//
//  Storage.swift
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

protocol StorageProvider {
  var version: Int { get }
  func save(_ data: Data, withKey key: String) throws
  func get(_ key: String) throws -> Data
  func removeValue(for key: String) throws
  func getAll() throws -> [Data]
}

struct Entry {
  let key: String
  let value: Data
}

protocol Migration {
  var startVersion: Int { get }
  var endVersion: Int { get }
  /**
   Perform a migration from startVersion to endVersion. Take into account that migrations could be performed for newer versions
   when reinstalling (when clearStorageOnReinstall is false), so validate that the data needs the migration.
   
   - Returns:returns an array of data that needs to be migrated, adding/removing fields, etc. Empty to skip the migration.
  */
  func migrate(data: [Data]) -> [Entry]
}

class Storage {
  
  private let secureStorage: SecureStorageProvider
  private let userDefaults: UserDefaults
  
  init(secureStorage: SecureStorageProvider = SecureStorage(),
       userDefaults: UserDefaults = .standard,
       migrations: [Migration],
       clearStorageOnReinstall: Bool = true) throws {
    self.secureStorage = secureStorage
    self.userDefaults = userDefaults
    try checkMigrations(migrations, clearStorageOnReinstall: clearStorageOnReinstall)
  }
}

extension Storage: StorageProvider {
  var version: Int {
    Constants.version
  }
  
  func save(_ data: Data, withKey key: String) throws {
    try secureStorage.save(data, withKey: key)
  }
  
  func get(_ key: String) throws -> Data {
    try secureStorage.get(key)
  }
  
  func getAll() throws -> [Data] {
    try secureStorage.getAll()
  }
  
  func removeValue(for key: String) throws {
    try secureStorage.removeValue(for: key)
  }
}

private extension Storage {
  func checkMigrations(_ migrations: [Migration], clearStorageOnReinstall: Bool) throws {
    var currentVersion = userDefaults.integer(forKey: Constants.currentVersionKey)
    guard currentVersion < version else {
      return
    }
    if currentVersion == Constants.noVersion && clearStorageOnReinstall {
      try clear()
      updateVersion(version: Constants.version)
      return
    }
    for migration in migrations {
      if migration.startVersion < currentVersion {
        continue
      }
      try applyMigration(migration)
      currentVersion = migration.endVersion
      if currentVersion == version {
        break
      }
    }
  }
  
  func applyMigration(_ migration: Migration) throws {
    let migrationResult = migration.migrate(data: try getAll())
    for result in migrationResult {
      try save(result.value, withKey: result.key)
    }
    updateVersion(version: migration.endVersion)
  }
  
  func updateVersion(version: Int) {
    userDefaults.set(version, forKey: Constants.currentVersionKey)
  }
  
  func clear() throws {
    try secureStorage.clear()
  }
}

extension Storage {
  struct Constants {
    static let currentVersionKey = "currentVersion"
    static let version = 1
    static let noVersion = 0
  }
}
