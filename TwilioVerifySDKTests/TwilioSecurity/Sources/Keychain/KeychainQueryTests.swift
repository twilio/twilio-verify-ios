//
//  KeychainQueryTests.swift
//  TwilioSecurityTests
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

// swiftlint:disable force_cast
class KeychainQueryTests: XCTestCase {

  var keychain: KeychainMock!
  var signer: SignerTemplate!
  var keychainQuery: KeychainQueryProtocol!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    keychain = KeychainMock()
    XCTAssertNoThrow(
      signer = try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: false, allowIphoneMigration: false)
    )
    keychainQuery = KeychainQuery(accessGroup: nil)
  }
  
  func testKey_withPrivateKey_shouldReturnValidQuery() {
    let expectedKeyClass = kSecAttrKeyClassPrivate
    let query = keychainQuery.key(withTemplate: signer, class: .private)
    let keyClass = query[kSecAttrKeyClass] as! CFString
    let label = query[kSecAttrLabel] as! String
    let keyType = query[kSecAttrKeyType] as! CFString

    XCTAssertEqual(keyClass, expectedKeyClass)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(keyType, kSecAttrKeyTypeECSECPrimeRandom)
  }
  
  func testKey_withPublicKey_shouldReturnValidQuery() {
    let expectedKeyClass = kSecAttrKeyClassPublic
    let query = keychainQuery.key(withTemplate: signer, class: .public)
    let keyClass = query[kSecAttrKeyClass] as! CFString
    let label = query[kSecAttrLabel] as! String
    let keyType = query[kSecAttrKeyType] as! CFString

    XCTAssertEqual(keyClass, expectedKeyClass)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(keyType, kSecAttrKeyTypeECSECPrimeRandom)
  }
  
  func testSaveKey_withKey_shouldReturnValidQuery() {
    var pair: KeyPair!
    let expectedClass = kSecClassKey
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    let query = keychainQuery.saveKey(pair.privateKey, withAlias: Constants.alias, allowIphoneMigration: false)
    let secClass = query[kSecClass] as! CFString
    let label = query[kSecAttrLabel] as! String
    let key = query[kSecValueRef] as! SecKey
    
    XCTAssertEqual(secClass, expectedClass)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(key, pair.privateKey)
  }
  
  func testSaveData_withKey_shouldReturnValidQuery() {
    let expectedData = "data".data(using: .utf8)!
    let query = keychainQuery.save(data: expectedData, withKey: Constants.alias, withServiceName: Constants.service, allowIphoneMigration: false)
    let keyClass = query[kSecClass] as! CFString
    let label = query[kSecAttrAccount] as! String
    let access = query[kSecAttrAccessible] as! CFString
    let data = query[kSecValueData] as! Data
    
    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(access, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
    XCTAssertEqual(data, expectedData)
  }
  
  func testGetData_withKey_shouldReturnValidQuery() {
    let query = keychainQuery.getData(withKey: Constants.alias)
    let keyClass = query[kSecClass] as! CFString
    let label = query[kSecAttrAccount] as! String
    
    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(label, Constants.alias)
  }
  
  func testGetAllData_shouldReturnValidQuery() {
    let queries = keychainQuery.getAll(withServiceName: nil)
    for query in queries {
      let keyClass = query[kSecClass] as! CFString
      let returnAttributes = query[kSecReturnAttributes] as! CFBoolean
      let returnData = query[kSecReturnData] as! CFBoolean
      let matchLimit = query[kSecMatchLimit] as! CFString

      XCTAssertEqual(keyClass, kSecClassGenericPassword)
      XCTAssertTrue(returnAttributes as! Bool)
      XCTAssertTrue(returnData as! Bool)
      XCTAssertEqual(matchLimit, kSecMatchLimitAll)
    }
  }
  
  func testDelete_withKey_shouldReturnValidQuery() {
    let query = keychainQuery.delete(withKey: Constants.alias)
    let keyClass = query[kSecClass] as! CFString
    let label = query[kSecAttrAccount] as! String
    
    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(label, Constants.alias)
  }
  
  func testDeleteItems_shouldReturnValidQuery() {
    let query = keychainQuery.deleteItems(withServiceName: Constants.service)
    let keyClass = query[kSecClass] as! CFString
    let service = query[kSecAttrService] as! String
    
    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(service, Constants.service)
  }

  func testGetItem_withOutAccessGroup_shouldReturnValidQuery() {
    keychainQuery = KeychainQuery(accessGroup: nil)
    let query = keychainQuery.getData(withKey: Constants.alias)
    let keyClass = query[kSecClass] as! CFString
    let label = query[kSecAttrAccount] as! String
    let accessGroup = query[kSecAttrAccessGroup] as? String

    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertNil(accessGroup)
  }

  func testSaveItem_withAccessGroup_shouldReturnValidQuery() {
    keychainQuery = KeychainQuery(accessGroup: Constants.accessGroup)
    let expectedData = "data".data(using: .utf8)!
    let query = keychainQuery.save(data: expectedData, withKey: Constants.alias, withServiceName: nil, allowIphoneMigration: false)
    let keyClass = query[kSecClass] as! CFString
    let label = query[kSecAttrAccount] as! String
    let access = query[kSecAttrAccessible] as! CFString
    let data = query[kSecValueData] as! Data
    let accessGroup = query[kSecAttrAccessGroup] as! String

    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(access, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
    XCTAssertEqual(data, expectedData)
    XCTAssertEqual(accessGroup, Constants.accessGroup)
  }

  func testSaveItem_withAttrAccessible_shouldReturnValidQuery() {
    keychainQuery = KeychainQuery(accessGroup: Constants.accessGroup)
    let expectedData = "data".data(using: .utf8)!
    let query = keychainQuery.save(data: expectedData, withKey: Constants.alias, withServiceName: nil, allowIphoneMigration: true)
    let keyClass = query[kSecClass] as! CFString
    let label = query[kSecAttrAccount] as! String
    let access = query[kSecAttrAccessible] as! CFString
    let data = query[kSecValueData] as! Data
    let accessGroup = query[kSecAttrAccessGroup] as! String

    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(access, kSecAttrAccessibleAfterFirstUnlock)
    XCTAssertEqual(data, expectedData)
    XCTAssertEqual(accessGroup, Constants.accessGroup)
  }
}

private extension KeychainQueryTests {
  struct Constants {
    static let alias = "signerAlias"
    static let service = "service"
    static let accessGroup = "teamID.com.myAccessGroup"
  }
}
