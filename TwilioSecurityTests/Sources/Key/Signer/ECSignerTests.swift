//
//  ECSignerTests.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioSecurity

class ECSignerTests: XCTestCase {

  var keyPair: KeyPair!
  var keychain: KeychainMock!
  var signer: Signer!
  
  override func setUp() {
    keyPair = KeyPairFactory.createKeyPair()
    keychain = KeychainMock()
    signer = ECSigner(
      withKeyPair: keyPair,
      signatureAlgorithm: .ecdsaSignatureMessageX962SHA256,
      keychain: keychain
    )
  }
  
  func testSign_withKeychainError_shouldThrow() {
    let data = "data".data(using: .utf8)!
    keychain.error = TestError.operationFailed
    XCTAssertThrowsError(try signer.sign(data), "Sign should throw") { error in
      XCTAssertEqual(error as! TestError, TestError.operationFailed)
    }
  }
  
  func testSign_withoutKeychainError_shouldReturnSignature() {
    let data = "data".data(using: .utf8)!
    let expectedSignature = "signature".data(using: .utf8)!
    keychain.operationResult =  expectedSignature
    XCTAssertNoThrow(try signer.sign(data), "Sign should not throw")
    let signature = try! signer.sign(data)
    XCTAssertEqual(signature, expectedSignature, "Signature should be \(expectedSignature) but was \(signature)")
  }
  
  func testVerify_withKeychainError_shouldReturnFalse() {
    let data = "data".data(using: .utf8)!
    let signature = "signature".data(using: .utf8)!
    keychain.verifyShouldSucceed = false
    let isValid = signer.verify(data, withSignature: signature)
    XCTAssertFalse(isValid, "Verify should return false")
  }
  
  func testVerify_withoutKeychainError_shouldReturnTrue() {
    let data = "data".data(using: .utf8)!
    let signature = "signature".data(using: .utf8)!
    keychain.verifyShouldSucceed = true
    let isValid = signer.verify(data, withSignature: signature)
    XCTAssertTrue(isValid, "Verify should return true")
  }
  
  func testGetPublic_withError_shouldThrow() {
    keychain.error = TestError.operationFailed
    XCTAssertThrowsError(try signer.getPublic(), "Get Public should throw") { error in
      XCTAssertEqual(error as! TestError, TestError.operationFailed)
    }
  }
}
