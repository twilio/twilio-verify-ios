//
//  KeychainQueryTests.swift
//  TwilioSecurityTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import XCTest
@testable import TwilioVerify

// swiftlint:disable force_cast
class KeychainQueryTests: XCTestCase {

  var keychain: KeychainMock!
  var signer: SignerTemplate!
  var keychainQuery: KeychainQueryProtocol!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    keychain = KeychainMock()
    XCTAssertNoThrow(signer = try ECP256SignerTemplate(withAlias: Constants.alias,
                                                       shouldExist: false,
                                                       keychain: keychain))
    keychainQuery = KeychainQuery()
  }
  
  func testKey_withPrivateKey_shouldReturnValidQuery() {
    let expectedKeyClass = kSecAttrKeyClassPrivate
    let query = keychainQuery.key(withTemplate: signer, class: .private)
    let keyClass = query[kSecAttrKeyClass as String] as! CFString
    let label = query[kSecAttrLabel as String] as! String
    let keyType = query[kSecAttrKeyType as String] as! CFString
    
    XCTAssertEqual(keyClass, expectedKeyClass)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(keyType, kSecAttrKeyTypeECSECPrimeRandom)
  }
  
  func testKey_withPublicKey_shouldReturnValidQuery() {
    let expectedKeyClass = kSecAttrKeyClassPublic
    let query = keychainQuery.key(withTemplate: signer, class: .public)
    let keyClass = query[kSecAttrKeyClass as String] as! CFString
    let label = query[kSecAttrLabel as String] as! String
    let keyType = query[kSecAttrKeyType as String] as! CFString
    
    XCTAssertEqual(keyClass, expectedKeyClass)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(keyType, kSecAttrKeyTypeECSECPrimeRandom)
  }
  
  func testSaveKey_withKey_shouldReturnValidQuery() {
    var pair: KeyPair!
    let expectedClass = kSecClassKey
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    let query = keychainQuery.saveKey(pair.privateKey, withAlias: Constants.alias)
    let secClass = query[kSecClass as String] as! CFString
    let label = query[kSecAttrLabel as String] as! String
    let key = query[kSecValueRef as String] as! SecKey
    
    XCTAssertEqual(secClass, expectedClass)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(key, pair.privateKey)
  }
  
  func testSaveData_withKey_shouldReturnValidQuery() {
    let expectedData = "data".data(using: .utf8)!
    let query = keychainQuery.save(data: expectedData, withKey: Constants.alias)
    let keyClass = query[kSecClass as String] as! CFString
    let label = query[kSecAttrAccount as String] as! String
    let access = query[kSecAttrAccessible as String] as! CFString
    let data = query[kSecValueData as String] as! Data
    
    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(access, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
    XCTAssertEqual(data, expectedData)
  }
  
  func testGetData_withKey_shouldReturnValidQuery() {
    let query = keychainQuery.getData(withKey: Constants.alias)
    let keyClass = query[kSecClass as String] as! CFString
    let label = query[kSecAttrAccount as String] as! String
    let access = query[kSecAttrAccessible as String] as! CFString
    
    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(access, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
  }
  
  func testGetAllData_shouldReturnValidQuery() {
    let query = keychainQuery.getAll()
    let keyClass = query[kSecClass as String] as! CFString
    let returnAttributes = query[kSecReturnAttributes as String] as! CFBoolean
    let returnData = query[kSecReturnData as String] as! CFBoolean
    let matchLimit = query[kSecMatchLimit as String] as! CFString
    let access = query[kSecAttrAccessible as String] as! CFString
    
    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertTrue(returnAttributes as! Bool)
    XCTAssertTrue(returnData as! Bool)
    XCTAssertEqual(matchLimit, kSecMatchLimitAll)
    XCTAssertEqual(access, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
  }
  
  func testDelete_withKey_shouldReturnValidQuery() {
    let query = keychainQuery.delete(withKey: Constants.alias)
    let keyClass = query[kSecClass as String] as! CFString
    let label = query[kSecAttrAccount as String] as! String
    let access = query[kSecAttrAccessible as String] as! CFString
    
    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(access, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
  }
  
  func testDeleteItems_shouldReturnValidQuery() {
    let query = keychainQuery.deleteItems()
    let keyClass = query[kSecClass as String] as! CFString
    let access = query[kSecAttrAccessible as String] as! CFString
    
    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(access, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
  }
}

private extension KeychainQueryTests {
  struct Constants {
    static let alias = "signerAlias"
  }
}
