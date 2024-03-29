//
//  KeyStorageAdapterTests.swift
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

// swiftlint:disable force_cast
class KeyStorageAdapterTests: XCTestCase {

  var signer: SignerMock!
  var keyManager: KeyManagerMock!
  var keyStorage: KeyStorage!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    signer = SignerMock()
    keyManager = KeyManagerMock()
    keyStorage = KeyStorageAdapter(keyManager: keyManager)
  }
  
  func testCreateKey_errorGettingSigner_shouldThrow() {
    keyManager.error = TestError.operationFailed
    XCTAssertThrowsError(try keyStorage.createKey(withAlias: Constants.alias), "Create key should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testCreateKey_errorGettingPublicKey_shouldThrow() {
    keyManager.signer = signer
    signer.error = TestError.operationFailed
    XCTAssertThrowsError(try keyStorage.createKey(withAlias: Constants.alias), "Create key should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testCreateKey_withoutErrors_shouldReturnPublicKey() {
    var key: String!
    let expectedKey = Constants.data.base64EncodedString()
    signer.operationresult = Constants.data
    keyManager.signer = signer
    XCTAssertNoThrow(key = try keyStorage.createKey(withAlias: Constants.alias), "Create key shouldn't throw")
    XCTAssertEqual(key, expectedKey, "Key should be \(expectedKey) but was \(key!)")
  }
  
  func testSign_errorGettingSigner_shouldThrow() {
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed)
    keyManager.error = TestError.operationFailed
    XCTAssertThrowsError(try keyStorage.sign(withAlias: Constants.alias, message: Constants.message), "Create key should throw") { error in
      XCTAssertEqual((error as! TwilioVerifyError).originalError.toEquatableError(), expectedError.originalError.toEquatableError())
    }
  }
  
  func testSign_errorGettingPublicKey_shouldThrow() {
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed)
    keyManager.signer = signer
    signer.error = TestError.operationFailed
    XCTAssertThrowsError(try keyStorage.sign(withAlias: Constants.alias, message: Constants.message), "Create key should throw") { error in
      XCTAssertEqual((error as! TwilioVerifyError).originalError.toEquatableError(), expectedError.originalError.toEquatableError())
    }
  }
  
  func testSign_withoutErrors_shouldReturnSignature() {
    var signature: Data!
    signer.operationresult = Constants.data
    keyManager.signer = signer
    XCTAssertNoThrow(
      signature = try keyStorage.sign(withAlias: Constants.alias, message: Constants.message),
      "Create key shouldn't throw"
    )
    XCTAssertEqual(signature, Constants.data, "Key should be \(Constants.data) but was \(signature!)")
  }
  
  func testSignAndEncode_errorGettingSigner_shouldThrow() {
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed)
    keyManager.error = TestError.operationFailed
    XCTAssertThrowsError(try keyStorage.signAndEncode(withAlias: Constants.alias, message: Constants.message), "Create key should throw") { error in
      XCTAssertEqual((error as! TwilioVerifyError).originalError.toEquatableError(), expectedError.originalError.toEquatableError())
    }
  }
  
  func testSignAndEncode_errorGettingPublicKey_shouldThrow() {
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed)
    keyManager.signer = signer
    signer.error = TestError.operationFailed
    XCTAssertThrowsError(try keyStorage.signAndEncode(withAlias: Constants.alias, message: Constants.message), "Create key should throw") { error in
      XCTAssertEqual((error as! TwilioVerifyError).originalError.toEquatableError(), expectedError.originalError.toEquatableError())
    }
  }
  
  func testSignAndEncode_withoutErrors_shouldReturnSignature() {
    var signature: String!
    let expectedSignature = Constants.data.base64EncodedString()
    signer.operationresult = Constants.data
    keyManager.signer = signer
    XCTAssertNoThrow(
      signature = try keyStorage.signAndEncode(withAlias: Constants.alias, message: Constants.message),
      "Create key shouldn't throw"
    )
    XCTAssertEqual(signature, expectedSignature, "Key should be \(expectedSignature) but was \(signature!)")
  }
  
  func testDelete_successfully_shouldNotThrow() {
    XCTAssertNoThrow(try keyStorage.deleteKey(withAlias: Constants.alias), "Delete key should not throw")
  }
  
  func testRemoveValue_unsuccessfully_shouldThrow() {
    keyManager.error = TestError.operationFailed
    XCTAssertThrowsError(try keyStorage.deleteKey(withAlias: Constants.alias), "Delete key should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
}

private extension KeyStorageAdapterTests {
  struct Constants {
    static let alias = "alias"
    static let message = "message"
    static let data = "data".data(using: .utf8)!
  }
}
