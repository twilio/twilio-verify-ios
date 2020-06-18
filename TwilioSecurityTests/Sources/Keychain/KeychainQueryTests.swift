//
//  KeychainQueryTests.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 6/1/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioSecurity

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
  
  func testDelete_withKey_shouldReturnValidQuery() {
    let query = keychainQuery.delete(withKey: Constants.alias, class: .genericPassword)
    let keyClass = query[kSecClass as String] as! CFString
    let label = query[kSecAttrAccount as String] as! String
    let access = query[kSecAttrAccessible as String] as! CFString
    
    XCTAssertEqual(keyClass, kSecClassGenericPassword)
    XCTAssertEqual(label, Constants.alias)
    XCTAssertEqual(access, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
  }
}

private extension KeychainQueryTests {
  struct Constants {
    static let alias = "signerAlias"
  }
}
