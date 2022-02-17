//
//  Storage+AccessGroupTests.swift
//  TwilioVerifySDKTests
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

import XCTest
@testable import TwilioVerifySDK

class StorageAccessGroupTests: XCTestCase {

  var secureStorage = SecureStorageMock()
  var userDefaults: UserDefaults!
  var factorMapper: FactorMapperMock!
  var storage: StorageProvider!

  enum Errors: Error {
    case empty
  }

  var factor: Factor {
    PushFactor(
      status: .unverified,
      sid: "factorSid123",
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      createdAt: Date(),
      config: Config(credentialSid: "123")
    )
  }

  func setUp(accessGroup: String?) {
    userDefaults = UserDefaults(suiteName: #file)
    userDefaults.removePersistentDomain(forName: #file)
    factorMapper = .init()
    factorMapper.error = Errors.empty

    storage = try? Storage(
      secureStorage: secureStorage,
      userDefaults: userDefaults,
      factorMapper: factorMapper,
      migrations: [],
      clearStorageOnReinstall: false,
      accessGroup: accessGroup
    )

    factorMapper.error = nil
  }

  func testInitWithoutPreviousAccessGroupShouldMigrateToAccessGroup() {
    // Given
    setUp(accessGroup: nil)
    let expectedAccessGroup = "com.twilioVerify.myAccessGroup"
    let factor = self.factor
    factorMapper.expectedFactor = factor

    guard let expectedFactorData = try? factorMapper.toData(factor) else {
      XCTFail("Failed to convert factor to data")
      return
    }

    try? storage.save(expectedFactorData, withKey: factor.sid)

    // When
    setUp(accessGroup: expectedAccessGroup)

    // Then
    guard let factorData = try? storage.get(factor.sid) else {
      XCTFail("Failed to obtain the factor data from storage")
      return
    }

    factorMapper.expectedData = factorData

    guard let retrieveFactor = try? factorMapper.fromStorage(withData: factorData) else {
      XCTFail("Failed to convert data to factor")
      return
    }

    XCTAssertEqual(storage.value(for: "accessGroup"), expectedAccessGroup)
    XCTAssertEqual(userDefaults.value(forKey: "currentVersion") as? Int, 1)
    XCTAssertEqual(retrieveFactor.friendlyName, factor.friendlyName)
  }

  func testInitWithPreviousAccessGroupShouldMigrateFromAccessGroup() {
    // Given
    let expectedAccessGroup = "com.twilioVerify.myAccessGroup"
    setUp(accessGroup: expectedAccessGroup)

    let factor = self.factor
    factorMapper.expectedFactor = factor

    guard let expectedFactorData = try? factorMapper.toData(factor) else {
      XCTFail("Failed to convert factor to data")
      return
    }

    try? storage.save(expectedFactorData, withKey: factor.sid)

    // When
    setUp(accessGroup: nil)

    // Then
    guard let factorData = try? storage.get(factor.sid) else {
      XCTFail("Failed to obtain the factor data from storage")
      return
    }

    factorMapper.expectedData = factorData

    guard let retrieveFactor = try? factorMapper.fromStorage(withData: factorData) else {
      XCTFail("Failed to convert data to factor")
      return
    }

    XCTAssertEqual(storage.value(for: "accessGroup"), nil)
    XCTAssertEqual(userDefaults.value(forKey: "currentVersion") as? Int, 1)
    XCTAssertEqual(retrieveFactor.friendlyName, factor.friendlyName)
  }
}
