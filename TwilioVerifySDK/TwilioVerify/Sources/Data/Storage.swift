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

// MARK: - Storage

class Storage {

  private let secureStorage: SecureStorageProvider
  private let userDefaults: UserDefaults
  private let factorMapper: FactorMapperProtocol

  init(
    secureStorage: SecureStorageProvider,
    keychain: KeychainProtocol,
    userDefaults: UserDefaults = .standard,
    factorMapper: FactorMapperProtocol = FactorMapper(),
    migrations: [Migration],
    clearStorageOnReinstall: Bool = true,
    accessGroup: String? = nil
  ) throws {
    self.secureStorage = secureStorage
    self.userDefaults = userDefaults
    self.factorMapper = factorMapper
    checkAccessGroupMigration(for: accessGroup, using: keychain)
    try checkMigrations(migrations, clearStorageOnReinstall: clearStorageOnReinstall)
  }
}

// MARK: - StorageProvider Implementation

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

// MARK: - Storage Migrations Implementation

private extension Storage {

  // MARK: Properties

  var isAppExtension: Bool {
    return Bundle.main.bundlePath.hasSuffix(Constants.appExtensionSuffix)
  }

  var storedCurrentVersion: Int {
    get { userDefaults.integer(forKey: Constants.currentVersionKey) }
    set { userDefaults.set(newValue, forKey: Constants.currentVersionKey) }
  }

  var storedAccessGroup: String? {
    get { value(for: Constants.accessGroup) }
    set { setValue(newValue, for: Constants.accessGroup) }
  }

  var storedClearOnReinstall: Bool? {
    get { bool(for: Constants.clearStorageOnReinstallKey) }
    set { setBool(newValue, for: Constants.clearStorageOnReinstallKey) }
  }

  // MARK: Methods

  func checkMigrations(_ migrations: [Migration], clearStorageOnReinstall: Bool) throws {
    if isAppExtension {
      Logger.shared.log(withLevel: .debug, message: "Migrations are not available for app extensions.")
      return
    }

    var currentVersion = storedCurrentVersion
    let accessGroup = storedAccessGroup

    guard currentVersion < version else {
      return
    }

    if currentVersion == Constants.noVersion && clearStorageOnReinstall && storedClearOnReinstall != nil {
      try? clearItemsWithoutService()
      try clear()
      storedCurrentVersion = Constants.version
      storedClearOnReinstall = clearStorageOnReinstall
      storedAccessGroup = accessGroup
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

    storedCurrentVersion = version
    storedClearOnReinstall = clearStorageOnReinstall
  }
  
  func applyMigration(_ migration: Migration) throws {
    let migrationResult = migration.migrate(data: try getAll())
    for result in migrationResult {
      try save(result.value, withKey: result.key)
    }
    storedCurrentVersion = migration.endVersion
  }
  
  func clearItemsWithoutService() throws {
    let migration = AddKeychainServiceToFactors(secureStorage: secureStorage)
    let migrationResult = migration.migrate(data: try secureStorage.getAll(withServiceName: Constants.service))
    for result in migrationResult {
      try removeValue(for: result.key)
    }
  }

  func checkAccessGroupMigration(
    for accessGroup: String?,
    using keychain: KeychainProtocol
  ) {
    if isAppExtension {
      Logger.shared.log(withLevel: .debug, message: "Migrations are not available for app extensions.")
      return
    }

    let migrationDirection: MigrationDirection

    switch (storedAccessGroup != nil, accessGroup != nil) {
      case (false, true): migrationDirection = .toAccessGroup
      case (true, false): migrationDirection = .fromAccessGroup
      default: return
    }

    Logger.shared.log(withLevel: .debug, message: "Migrating Factors in direction: \(migrationDirection)")

    var lastAccessGroup: String?

    switch migrationDirection {
      case .toAccessGroup:
        guard let accessGroup = accessGroup else { return }
        let factors = getAllFactors(using: factorMapper, keychain: keychain)

        do {
          try updateFactors(factors, with: accessGroup, keychain: keychain)
          storedAccessGroup = accessGroup
        } catch {
          Logger.shared.log(
            withLevel: .error,
            message: """
              Factors migration to AccessGroup failed due to: \(error).
              Other apps/extensions may not be able to use factors
            """
          )
        }

        lastAccessGroup = accessGroup
      case .fromAccessGroup:
        lastAccessGroup = storedAccessGroup
        try? removeValue(for: Constants.accessGroup)
    }

    Logger.shared.log(withLevel: .debug, message: "Migrating UserDefaults in direction: \(migrationDirection)")

    migrate(key: Constants.currentVersionKey, direction: migrationDirection, with: lastAccessGroup)
    migrate(key: Constants.timeCorrection, direction: migrationDirection, with: lastAccessGroup)
  }
}

extension Storage {
  struct Constants {
    static let currentVersionKey = "currentVersion"
    static let version = 1
    static let noVersion = 0
    static let service = "TwilioVerify"
    static let clearStorageOnReinstallKey = "clearStorageOnReinstall"
    static let accessGroup = "accessGroup"
    static let timeCorrection = "timeCorrection"
    static let appExtensionSuffix = ".appex"
  }
}
