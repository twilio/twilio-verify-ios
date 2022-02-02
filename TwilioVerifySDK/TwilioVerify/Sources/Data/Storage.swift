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
  func clear() throws
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
    try secureStorage.save(data, withKey: key, withServiceName: Constants.service)
  }
  
  func get(_ key: String) throws -> Data {
    try secureStorage.get(key)
  }
  
  func getAll() throws -> [Data] {
    try secureStorage.getAll(withServiceName: nil)
  }
  
  func removeValue(for key: String) throws {
    try secureStorage.removeValue(for: key)
  }
  
  func clear() throws {
    try secureStorage.clear(withServiceName: Constants.service)
  }
}

private extension Storage {

  var isAppExtension: Bool {
    return Bundle.main.bundlePath.hasSuffix(Constants.appExtension)
  }

  func checkMigrations(_ migrations: [Migration], clearStorageOnReinstall: Bool) throws {

    if isAppExtension {
      NSLog("Migrations are not available for app extensions.")
      return
    }

    var currentVersion = userDefaults.integer(forKey: Constants.currentVersionKey)
    guard currentVersion < version else {
      return
    }
    let previousClearStorageOnReinstall = previousClearStorageOnReinstallValue()
    if currentVersion == Constants.noVersion && clearStorageOnReinstall && previousClearStorageOnReinstall != nil {
      try? clearItemsWithoutService()
      try clear()
      updateVersion(version: Constants.version)
      updateClearStorageOnReinstall(value: clearStorageOnReinstall)
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
    updateVersion(version: version)
    updateClearStorageOnReinstall(value: clearStorageOnReinstall)
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
  
  func clearItemsWithoutService() throws {
    let migration = AddKeychainServiceToFactors(secureStorage: secureStorage)
    let migrationResult = migration.migrate(data: try secureStorage.getAll(withServiceName: Constants.service))
    for result in migrationResult {
      try removeValue(for: result.key)
    }
  }
  
  func previousClearStorageOnReinstallValue() -> Bool? {
    guard let clearStorageOnReinstallValue = try? get(Constants.clearStorageOnReinstallKey) else {
      return nil
    }
    return Bool(String(decoding: clearStorageOnReinstallValue, as: UTF8.self))
  }
  
  func updateClearStorageOnReinstall(value: Bool) {
    guard let clearStorageOnReinstallValue = value.description.data(using: .utf8) else {
      return
    }
    try? secureStorage.save(clearStorageOnReinstallValue, withKey: Constants.clearStorageOnReinstallKey, withServiceName: Constants.service)
  }
}

extension Storage {
  struct Constants {
    static let currentVersionKey = "currentVersion"
    static let version = 1
    static let noVersion = 0
    static let service = "TwilioVerify"
    static let clearStorageOnReinstallKey = "clearStorageOnReinstall"
    static let appExtension = ".appex"
  }
}
