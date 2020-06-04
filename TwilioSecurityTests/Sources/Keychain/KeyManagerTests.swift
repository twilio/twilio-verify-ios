//
//  KeyManagerTests.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 6/1/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioSecurity

class KeyManagerTests: XCTestCase {

  var keychain: KeychainMock!
  var keyManager: KeyManager!
  
  override func setUpWithError() throws {
    keychain = KeychainMock()
    keyManager = KeyManager(withKeychain: keychain)
  }
  
  func testKey_withoutMatches_shouldThrow() {
    keychain.error = TestError.operationFailed
    XCTAssertThrowsError(try keyManager.key(withQuery: Constants.keyQuery), "Key should throw") { error in
      XCTAssertEqual(
        error as! TestError,
        TestError.operationFailed,
        "Error should be \(TestError.operationFailed), but was \(error)"
      )
    }
  }
  
  func testKey_withMatches_shouldReturnKey() {
    var pair: KeyPair!
    var key: SecKey!
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    keychain.keys = [pair.publicKey]
    XCTAssertNoThrow(
      key = try keyManager.key(withQuery: Constants.keyQuery),
      "Key should not throw"
    )
    XCTAssertEqual(
      key,
      pair.publicKey,
      "Key should be \(pair.publicKey), but was \(key!)"
    )
  }
  
  func testKeyPair_withoutMatches_shouldThrow() {
    var template: SignerTemplate!
    keychain.error = TestError.operationFailed
    XCTAssertNoThrow(
      template =  try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: true),
      "Template should be created correclty"
    )
    XCTAssertThrowsError(try keyManager.keyPair(forTemplate: template), "keyPair should throw") { error in
      XCTAssertEqual(
        error as! TestError,
        TestError.operationFailed,
        "Error should be \(TestError.operationFailed), but was \(error)"
      )
    }
  }
  
  func testKeyPair_withMatches_shouldReturnKeyPair() {
    var template: SignerTemplate!
    var expectedPair: KeyPair!
    var pair: KeyPair!

    XCTAssertNoThrow(expectedPair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    keychain.keys = [expectedPair.publicKey, expectedPair.privateKey]
    XCTAssertNoThrow(
      template =  try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: true),
      "Template should be created correclty"
    )
    XCTAssertNoThrow(
      pair = try keyManager.keyPair(forTemplate: template),
      "KeyPair should not throw"
    )
    XCTAssertEqual(
      pair.publicKey,
      expectedPair.publicKey,
      "Public Key should be \(expectedPair.publicKey), but was \(pair.publicKey)"
    )
    XCTAssertEqual(
      pair.privateKey,
      expectedPair.privateKey,
      "Private Key should be \(expectedPair.privateKey), but was \(pair.privateKey)"
    )
  }
  
  func testGenerateKeyPair_withError_shouldThrow() {
    var template: SignerTemplate!
    keychain.error = TestError.operationFailed
    XCTAssertNoThrow(
      template =  try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: true),
      "Template should be created correclty"
    )
    XCTAssertThrowsError(try keyManager.generateKeyPair(withTemplate: template), "keyPair should throw") { error in
      XCTAssertEqual(
        error as! TestError,
        TestError.operationFailed,
        "Error should be \(TestError.operationFailed), but was \(error)"
      )
    }
  }
  
  func testGenerateKeyPair_withoutError_shouldReturnKeyPair() {
    var template: SignerTemplate!
    var expectedPair: KeyPair!
    var pair: KeyPair!

    XCTAssertNoThrow(expectedPair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    keychain.keyPair = expectedPair
    XCTAssertNoThrow(
      template =  try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: true),
      "Template should be created correclty"
    )
    XCTAssertNoThrow(
      pair = try keyManager.generateKeyPair(withTemplate: template),
      "Generate KeyPair should not throw"
    )
    XCTAssertEqual(
      pair.publicKey,
      expectedPair.publicKey,
      "Public Key should be \(expectedPair.publicKey), but was \(pair.publicKey)"
    )
    XCTAssertEqual(
      pair.privateKey,
      expectedPair.privateKey,
      "Private Key should be \(expectedPair.privateKey), but was \(pair.privateKey)"
    )
  }

  func testForceSavePublicKey() {
    
  }
}

private extension KeyManagerTests {
  struct Constants {
    static let alias = "alias"
    static let keyQuery = [kSecClass: kSecClassKey,
                           kSecAttrKeyClass: kSecAttrKeyClassPublic,
                           kSecAttrLabel: Constants.alias,
                           kSecReturnRef: true,
                           kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                           kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
}
