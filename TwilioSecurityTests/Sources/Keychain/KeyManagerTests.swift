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
    keychain.generateKeyPairError = TestError.operationFailed
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

  func testForceSavePublicKey_withFailureAddingItem_shouldThrow() {
    var pair: KeyPair!
    let expectedErrorCode: OSStatus = -50
    let expectedErrorDomain = "NSOSStatusErrorDomain"
    let expectedCallsToAddItem = 1
    let expectedCallOrder = [KeychainMethods.addItem]
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    keychain.addItemStatus = [expectedErrorCode]
    XCTAssertThrowsError(try keyManager.forceSavePublicKey(pair.publicKey, withAlias: Constants.alias), "Force save public key should throw") { error in
      let thrownError = error as NSError
      XCTAssertEqual(
        thrownError.code,
        Int(expectedErrorCode),
        "Error code should be \(expectedErrorCode), but was \(thrownError.code)"
      )
      XCTAssertEqual(
        thrownError.domain,
        expectedErrorDomain,
        "Error domain should be \(expectedErrorDomain), but was \(thrownError.domain)"
      )
    }
    XCTAssertEqual(
      keychain.callsToAddItem,
      expectedCallsToAddItem,
      "Add Item should be called \(expectedCallsToAddItem), but was called \(keychain.callsToAddItem)"
    )
    XCTAssertEqual(
      keychain.callOrder,
      expectedCallOrder,
      "Call order should be \(expectedCallOrder) but was \(keychain.callOrder)"
    )
  }
  
  func testForceSavePublicKey_keyAlreadyExistsErrorDeletingKey_shouldThrow() {
    var pair: KeyPair!
    let expectedErrorCode = errSecBadReq
    let expectedErrorDomain = "NSOSStatusErrorDomain"
    let expectedCallsToAddItem = 2
    let expectedCallOrder: [KeychainMethods] = [.addItem,
                                                .deleteItem,
                                                .addItem]
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    keychain.addItemStatus = [errSecDuplicateItem, expectedErrorCode]
    keychain.deleteItemStatus = -50
    XCTAssertThrowsError(try keyManager.forceSavePublicKey(pair.publicKey, withAlias: Constants.alias), "Force save public key should throw") { error in
      let thrownError = error as NSError
      XCTAssertEqual(
        thrownError.code,
        Int(expectedErrorCode),
        "Error code should be \(expectedErrorCode), but was \(thrownError.code)"
      )
      XCTAssertEqual(
        thrownError.domain,
        expectedErrorDomain,
        "Error domain should be \(expectedErrorDomain), but was \(thrownError.domain)"
      )
    }
    XCTAssertEqual(
      keychain.callsToAddItem,
      expectedCallsToAddItem,
      "Add Item should be called \(expectedCallsToAddItem), but was called \(keychain.callsToAddItem)"
    )
    XCTAssertEqual(
      keychain.callOrder,
      expectedCallOrder,
      "Call order should be \(expectedCallOrder) but was \(keychain.callOrder)"
    )
  }
  
  func testForceSavePublicKey_withoutError_shouldNotThrow() {
    var pair: KeyPair!
    let expectedCallsToAddItem = 2
    let expectedCallOrder: [KeychainMethods] = [.addItem,
                                                .deleteItem,
                                                .addItem]
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    keychain.addItemStatus = [errSecDuplicateItem, errSecSuccess]
    keychain.deleteItemStatus = errSecSuccess
    XCTAssertNoThrow(try keyManager.forceSavePublicKey(pair.publicKey, withAlias: Constants.alias),
                     "Force save public key should not throw")
    XCTAssertEqual(
      keychain.callsToAddItem,
      expectedCallsToAddItem,
      "Add Item should be called \(expectedCallsToAddItem), but was called \(keychain.callsToAddItem)"
    )
    XCTAssertEqual(
      keychain.callOrder,
      expectedCallOrder,
      "Call order should be \(expectedCallOrder) but was \(keychain.callOrder)"
    )
  }
  
  func testSigner_withErrorGettingKeyPairAndKeyPairShouldExist_shouldThrowError() {
    var template: SignerTemplate!
    keychain.error = TestError.operationFailed
    
    XCTAssertNoThrow(
      template =  try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: true),
      "Template should be created correclty"
    )
    XCTAssertThrowsError(try keyManager.signer(withTemplate: template), "Signer should throw") { error in
      XCTAssertEqual(
        error as! TestError,
        TestError.operationFailed,
        "Error should be \(TestError.operationFailed), but was \(error)"
      )
    }
  }
  
  func testSigner_withErrorGettingKeyPairAndKeyPairShouldNotExistAndErrorCreatingKeyPair_shouldThrowError() {
    var template: SignerTemplate!
    keychain.error = TestError.operationFailed
    keychain.generateKeyPairError = TestError.operationFailed
    XCTAssertNoThrow(
      template =  try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: false),
      "Template should be created correclty"
    )
    XCTAssertThrowsError(try keyManager.signer(withTemplate: template), "Signer should throw") { error in
      XCTAssertEqual(
        error as! TestError,
        TestError.operationFailed,
        "Error should be \(TestError.operationFailed), but was \(error)"
      )
    }
  }
  
  func testSigner_withErrorGettingKeyPairAndKeyPairShouldNotExistAndKeyPairCreationSucceeded_shouldReturnSigner() {
    var template: SignerTemplate!
    var pair: KeyPair!
    var signer: Signer!
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    keychain.keyPair = pair
    keychain.error = TestError.operationFailed
    keychain.addItemStatus = [errSecSuccess]
    XCTAssertNoThrow(
      template =  try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: false),
      "Template should be created correclty"
    )
    XCTAssertNoThrow(
      signer = try keyManager.signer(withTemplate: template),
      "signer should not throw"
    )
    XCTAssertNotNil(signer, "Signer should not be nil")
  }
  
  func testSigner_withErrorSavingKey_shouldThrow() {
    var template: SignerTemplate!
    var pair: KeyPair!
    let expectedErrorDomain = "NSOSStatusErrorDomain"
    let expectedErrorCode: OSStatus = -50

    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    keychain.keys = [pair.publicKey, pair.privateKey]
    keychain.addItemStatus = [-50]
    XCTAssertNoThrow(
      template =  try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: true),
      "Template should be created correclty"
    )
    XCTAssertThrowsError(try keyManager.signer(withTemplate: template), "Signer should throw") { error in
      let thrownError = error as NSError
      XCTAssertEqual(
        thrownError.code,
        Int(expectedErrorCode),
        "Error code should be \(expectedErrorCode), but was \(thrownError.code)"
      )
      XCTAssertEqual(
        thrownError.domain,
        expectedErrorDomain,
        "Error domain should be \(expectedErrorDomain), but was \(thrownError.domain)"
      )
    }
  }
  
  func testSigner_withoutErrors_shouldReturnSigner() {
    var template: SignerTemplate!
    var pair: KeyPair!
    var signer: Signer!

    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    keychain.keys = [pair.publicKey, pair.privateKey]
    keychain.addItemStatus = [errSecSuccess]
    XCTAssertNoThrow(
      template =  try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: true),
      "Template should be created correclty"
    )
    XCTAssertNoThrow(
      signer = try keyManager.signer(withTemplate: template),
      "signer should not throw"
    )
    XCTAssertNotNil(signer, "Signer should not be nil")
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
