//
//  StorageTests.swift
//  TwilioVerifyTests
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

import XCTest
@testable import TwilioVerifySDK

// swiftlint:disable force_cast force_try
class StorageTests: XCTestCase {

  var secureStorage: SecureStorageMock!
  var storage: StorageProvider!
  var keychainMock: KeychainMock!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    secureStorage = SecureStorageMock()
    keychainMock = .init()
    storage = try! Storage(
      secureStorage: secureStorage,
      keychain: keychainMock,
      migrations: [],
      clearStorageOnReinstall: false
    )
  }
  
  func testSave_successfully_shouldNotThrow() {
    XCTAssertNoThrow(try storage.save(Constants.data, withKey: Constants.key, allowIphoneMigration: false), "Save should not throw")
  }
  
  func testSave_unsucessfully_shouldThrow() {
    secureStorage.error = TestError.operationFailed
    XCTAssertThrowsError(try storage.save(Constants.data, withKey: Constants.key, allowIphoneMigration: false), "Get should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testGet_valueExists_shouldReturnValue() {
    var data: Data!
    let expectedData = Constants.data
    secureStorage.objectsData = [Constants.key: expectedData]
    
    XCTAssertNoThrow(data = try storage.get(Constants.key), "Get should not throw")
    XCTAssertEqual(data, expectedData, "Returned data should be \(expectedData), but wsa \(data!)")
  }
  
  func testGet_valueDoesNotExist_shouldThrow() {
    secureStorage.error = TestError.operationFailed
    XCTAssertThrowsError(try storage.get(Constants.key), "Get should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testGetAll_withExistingValue_shouldReturnValues() {
    var data: [Data?]!
    let expectedData = [Constants.data]
    let expectedCallsToMethod = 1
    secureStorage.objectsData = [Constants.key: Constants.data]
    
    XCTAssertNoThrow(data = try storage.getAll(), "Get all should not throw")
    XCTAssertEqual(data, expectedData, "Returned data should be \(expectedData), but wsa \(data!)")
    XCTAssertEqual(
      secureStorage.callsToGetAll,
      expectedCallsToMethod,
      "Get all should be called \(expectedCallsToMethod) time but was called \(secureStorage.callsToGet) times"
    )
  }
  
  func testGetAll_withError_shouldThrow() {
    secureStorage.error = TestError.operationFailed
    XCTAssertThrowsError(try storage.getAll(), "GetAll should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testRemoveValue_successfully_shouldNotThrow() {
    XCTAssertNoThrow(try storage.removeValue(for: Constants.key), "Remove value should not throw")
  }
  
  func testRemoveValue_unsuccessfully_shouldThrow() {
    secureStorage.error = TestError.operationFailed
    XCTAssertThrowsError(try storage.removeValue(for: Constants.key), "Remove value should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testInit_withClearStorageOnReinstall_shouldCallSecureStorageClear() {
    let expectedCallsToMethod = 1
    let userDefaults: UserDefaults = .standard
    userDefaults.removeObject(forKey: Storage.Constants.currentVersionKey)
    secureStorage.objectsData = [Storage.Constants.clearStorageOnReinstallKey: true.description.data(using: .utf8)!]
    storage = try! Storage(
      secureStorage: secureStorage,
      keychain: keychainMock,
      userDefaults: userDefaults,
      migrations: [],
      clearStorageOnReinstall: true
    )
    XCTAssertEqual(
      secureStorage.callsToClear,
      expectedCallsToMethod,
      "Clear should be called \(expectedCallsToMethod) but was called \(secureStorage.callsToClear)"
    )
    let currentVersion = userDefaults.integer(forKey: Storage.Constants.currentVersionKey)
    XCTAssertEqual(
      currentVersion,
      Storage.Constants.version,
      "Version should be \(Storage.Constants.version) but was \(currentVersion)"
    )
    XCTAssertTrue(
      secureStorage.objectsData[Storage.Constants.clearStorageOnReinstallKey] != nil,
      "ClearStorageOnReinstall should have a value"
    )
  }
  
  func testInit_withClearStorageOnReinstallAndNoPreviousValue_shouldNotCallSecureStorageClear() {
    let expectedCallsToMethod = 0
    let userDefaults: UserDefaults = .standard
    userDefaults.removeObject(forKey: Storage.Constants.currentVersionKey)
    storage = try! Storage(
      secureStorage: secureStorage,
      keychain: keychainMock,
      userDefaults: userDefaults,
      migrations: [],
      clearStorageOnReinstall: true
    )
    XCTAssertEqual(
      secureStorage.callsToClear,
      expectedCallsToMethod,
      "Clear should be called \(expectedCallsToMethod) but was called \(secureStorage.callsToClear)"
    )
    let currentVersion = userDefaults.integer(forKey: Storage.Constants.currentVersionKey)
    XCTAssertEqual(
      currentVersion,
      Storage.Constants.version,
      "Version should be \(Storage.Constants.version) but was \(currentVersion)"
    )
    XCTAssertTrue(
      secureStorage.objectsData[Storage.Constants.clearStorageOnReinstallKey] != nil,
      "ClearStorageOnReinstall should have a value"
    )
  }
  
  func testInit_withNoClearStorageOnReinstall_shouldNotCallSecureStorageClear() {
    let expectedCallsToMethod = 0
    let userDefaults: UserDefaults = .standard
    userDefaults.removeObject(forKey: Storage.Constants.currentVersionKey)
    storage = try! Storage(
      secureStorage: secureStorage,
      keychain: keychainMock,
      userDefaults: userDefaults,
      migrations: [],
      clearStorageOnReinstall: false
    )
    XCTAssertEqual(
      secureStorage.callsToClear,
      expectedCallsToMethod,
      "Clear should be called \(expectedCallsToMethod) but was called \(secureStorage.callsToClear)"
    )
  }
  
  func testInit_withClearStorageOnReinstallAndMigrations_shouldNotMigrate() {
    let expectedCallsToMethod = 0
    let userDefaults: UserDefaults = .standard
    userDefaults.removeObject(forKey: Storage.Constants.currentVersionKey)
    secureStorage.objectsData = [Storage.Constants.clearStorageOnReinstallKey: true.description.data(using: .utf8)!]
    let migrationV0ToV1 = MigrationMock(startVersion: 0, endVersion: 1)
    let migrations = [migrationV0ToV1]
    storage = try! Storage(
      secureStorage: secureStorage,
      keychain: keychainMock,
      userDefaults: userDefaults,
      migrations: migrations,
      clearStorageOnReinstall: true
    )
    XCTAssertEqual(
      migrationV0ToV1.callsToMigrate,
      expectedCallsToMethod,
      "Migrate should be called \(expectedCallsToMethod) but was called \(migrationV0ToV1.callsToMigrate)"
    )
    let currentVersion = userDefaults.integer(forKey: Storage.Constants.currentVersionKey)
    XCTAssertEqual(
      currentVersion,
      Storage.Constants.version,
      "Version should be \(Storage.Constants.version) but was \(currentVersion)"
    )
  }
  
  func testInit_withMigrations_shouldExecuteMigrations() {
    let expectedCallsToMethod = 1
    secureStorage.objectsData = [Constants.key: Constants.data]
    let migrationToV0 = MigrationMock(startVersion: -1, endVersion: 0)
    let migrationV0ToV1 = MigrationMock(startVersion: 0, endVersion: 1)
    let migrations = [migrationToV0, migrationV0ToV1]
    initStorage(withMigrations: migrations, withStartVersion: migrationToV0.startVersion, withEndVersion: migrationV0ToV1.endVersion)
    XCTAssertEqual(
      migrationToV0.callsToMigrate,
      expectedCallsToMethod,
      "Migrate should be called \(expectedCallsToMethod) but was called \(migrationToV0.callsToMigrate)"
    )
    XCTAssertEqual(
      migrationV0ToV1.callsToMigrate,
      expectedCallsToMethod,
      "Migrate should be called \(expectedCallsToMethod) but was called \(migrationV0ToV1.callsToMigrate)"
    )
  }
  
  func testInit_withMigrations_shouldExecuteMigration() {
    let expectedCallsToMethod = 1
    secureStorage.objectsData = [Constants.key: Constants.data]
    let migrationToV0 = MigrationMock(startVersion: -1, endVersion: 0)
    let migrationV0ToV1 = MigrationMock(startVersion: 0, endVersion: 1)
    let migrations = [migrationToV0, migrationV0ToV1]
    initStorage(withMigrations: migrations, withStartVersion: migrationV0ToV1.startVersion, withEndVersion: migrationV0ToV1.endVersion)
    XCTAssertEqual(
      migrationV0ToV1.callsToMigrate,
      expectedCallsToMethod,
      "Migrate should be called \(expectedCallsToMethod) but was called \(migrationV0ToV1.callsToMigrate)"
    )
    XCTAssertEqual(
      migrationToV0.callsToMigrate,
      0,
      "Migrate should be called \(expectedCallsToMethod) but was called \(migrationToV0.callsToMigrate)"
    )
  }
  
  func testInit_withStorageVersion_shouldNotMigrate() {
    let expectedCallsToMethod = 0
    secureStorage.objectsData = [Constants.key: Constants.data]
    let migrationV0ToV1 = MigrationMock(startVersion: 0, endVersion: 1)
    let migrations = [migrationV0ToV1]
    initStorage(withMigrations: migrations, withStartVersion: Storage.Constants.version, withEndVersion: Storage.Constants.version)
    XCTAssertEqual(
      migrationV0ToV1.callsToMigrate,
      expectedCallsToMethod,
      "Migrate should be called \(expectedCallsToMethod) but was called \(migrationV0ToV1.callsToMigrate)"
    )
  }
  
  func testInit_withMigrations_shouldMigrate() {
    let expectedCallsToMethod = 2
    secureStorage.objectsData = [Constants.key: Constants.data]
    let migrationV0ToV1 = MigrationMock(startVersion: 0, endVersion: 1)
    migrationV0ToV1.migrateData = migrate
    let migrations = [migrationV0ToV1]
    initStorage(withMigrations: migrations, withStartVersion: migrationV0ToV1.startVersion, withEndVersion: migrationV0ToV1.endVersion)
    XCTAssertEqual(
      secureStorage.callsToSave,
      expectedCallsToMethod,
      "Save should be called \(expectedCallsToMethod) but was called \(secureStorage.callsToSave)"
    )
  }
  
  func testClear_withError_shouldThrowError() {
    secureStorage.error = TestError.operationFailed
    XCTAssertThrowsError(try storage.clear(), "Clear should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testClear_withoutErrors_shouldClearSecureStorage() {
    XCTAssertNoThrow(try storage.clear(), "Clear should not throw")
  }
}

private extension StorageTests {
  struct Constants {
    static let key = "key"
    static let data = "data".data(using: .utf8)!
  }
  
  func initStorage(withMigrations migrations: [Migration], withStartVersion startVersion: Int, withEndVersion endVersion: Int) {
    let userDefaults: UserDefaults = .standard
    userDefaults.set(startVersion, forKey: Storage.Constants.currentVersionKey)
    storage = try! Storage(
      secureStorage: secureStorage,
      keychain: keychainMock,
      userDefaults: userDefaults,
      migrations: migrations,
      clearStorageOnReinstall: false
    )
    let currentVersion = userDefaults.integer(forKey: Storage.Constants.currentVersionKey)
    XCTAssertEqual(
      currentVersion,
      endVersion,
      "Version should be \(endVersion) but was \(currentVersion)"
    )
  }
  
  func migrate() -> [Entry] {
    [Entry(key: Constants.key, value: "new data".data(using: .utf8)!)]
  }
}
