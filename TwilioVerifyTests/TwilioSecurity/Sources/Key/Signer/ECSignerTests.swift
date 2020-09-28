//
//  ECSignerTests.swift
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
@testable import TwilioVerify

// swiftlint:disable force_cast
class ECSignerTests: XCTestCase {

  var keyPair: KeyPair!
  var keychain: KeychainMock!
  var signer: Signer!
  
  override func setUpWithError() throws {
    keyPair = try KeyPairFactory.createKeyPair()
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
    var signature: Data!
    XCTAssertNoThrow(signature = try signer.sign(data), "Sign should not throw")
    XCTAssertEqual(signature, expectedSignature, "Signature should be \(expectedSignature) but was \(signature!)")
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
  
  func testGetPublic_withoutError_shouldReturnData() {
    let data = "data".data(using: .utf8)!
    let expectedPublicKey = representation(for: data)
    var publicKey = Data()
    keychain.operationResult = data
    XCTAssertNoThrow(publicKey = try signer.getPublic(), "Get public should not throw")
    XCTAssertEqual(publicKey, expectedPublicKey, "PublicKey should be \(expectedPublicKey) but was \(publicKey)")
  }
}

private extension ECSignerTests {
  func representation(for data: Data) -> Data {
    let x962HeaderECHeader = [UInt8]([
    /* sequence          */ 0x30, 0x59,
    /* |-> sequence      */ 0x30, 0x13,
    /* |---> ecPublicKey */ 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, // http://oid-info.com/get/1.2.840.10045.2.1 (ANSI X9.62 public key type)
    /* |---> prime256v1  */ 0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, // http://oid-info.com/get/1.2.840.10045.3.1.7 (ANSI X9.62 named elliptic curve)
    /* |-> bit headers   */ 0x07, 0x03, 0x42, 0x00])

    var result = Data()
    result.append(Data(x962HeaderECHeader))
    result.append(data)
    return result
  }
}
