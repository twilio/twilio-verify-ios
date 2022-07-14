//
//  KeychainTests.swift
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
import Foundation
import LocalAuthentication
@testable import TwilioVerifySDK

// swiftlint:disable force_cast type_body_length
class KeychainTests: XCTestCase {
  
  var keychain: KeychainProtocol!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    keychain = Keychain(accessGroup: nil)
  }
  
  override func tearDown() {
    clearKeychain()
    super.tearDown()
  }
  
  func testAccessControl_withInvalidProtection_shouldThrow() {
    let expectedErrorCode = -50
    let expectedErrorDomain = "NSOSStatusErrorDomain"
    let expectedLocalizedDescription = "The operation couldn’t be completed. (OSStatus error -50 - SecAccessControl: invalid protection: )"
    
    XCTAssertThrowsError(
      try keychain.accessControl(withProtection: String() as CFString),
      "Access Control should throw", { error in
        
        guard let thrownError = error as? KeychainError,
              case .errorCreatingAccessControl(let cause) = thrownError else {
          XCTFail("Unexpected error received")
          return
        }

        let causeError = cause as NSError

        XCTAssertEqual(
          causeError.code,
          expectedErrorCode,
          "Error code should be \(expectedErrorCode), but was \(causeError.code)"
        )
        XCTAssertEqual(
          thrownError.domain,
          expectedErrorDomain,
          "Error domain should be \(expectedErrorDomain), but was \(thrownError.domain)"
        )
        XCTAssertTrue(
          thrownError.localizedDescription.contains(expectedLocalizedDescription),
          "Error localized description should be \(expectedLocalizedDescription), but was \(thrownError.localizedDescription)"
        )
      })
  }
  
  func testAccessControl_withValidProtection_shouldReturnAccesControl() {
    var accessControl: SecAccessControl!
    let accessControlProtection = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    guard let expectedAccessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, accessControlProtection, [], nil) else {
      XCTFail()
      return
    }
    XCTAssertNoThrow(accessControl = try  keychain.accessControl(withProtection: accessControlProtection))
    XCTAssertEqual(
      accessControl,
      expectedAccessControl,
      "Access control should be \(expectedAccessControl) but was \(accessControl!)"
    )
  }
  
  func testSign_withInvalidAlgorithm_shouldThrow() {
    let expectedErrorCode = -50
    let expectedErrorDomain = "NSOSStatusErrorDomain"
    let dataToSign = "data".data(using: .utf8)!
    var pair: KeyPair!
    
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    
    XCTAssertThrowsError(
      try keychain.sign(
        withPrivateKey: pair.privateKey,
        algorithm: .rsaSignatureDigestPKCS1v15SHA256,
        dataToSign: dataToSign), ""
    ) { error in
      
      guard let thrownError = error as? KeychainError,
            case .createSignatureError(let cause) = thrownError else {
        XCTFail("Unexpected error received")
        return
      }

      let causeError = cause as NSError
      
      XCTAssertEqual(
        causeError.code,
        expectedErrorCode,
        "Error code should be \(expectedErrorCode), but was \(causeError.code)"
      )
      XCTAssertEqual(
        thrownError.domain,
        expectedErrorDomain,
        "Error domain should be \(expectedErrorDomain), but was \(thrownError.domain)"
      )
    }
  }
  
  func testSign_withValidAlgorithm_shouldReturnSignature() {
    let dataToSign = "data".data(using: .utf8)!
    var pair: KeyPair!
    var signature: Data!
    
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    XCTAssertNoThrow(signature = try keychain.sign(withPrivateKey: pair.privateKey, algorithm: Constants.algorithm, dataToSign: dataToSign), "Sign should not throw")
    
    let isSignatureValid = SecKeyVerifySignature(
      pair.publicKey,
      .ecdsaSignatureMessageX962SHA256,
      dataToSign as CFData,
      signature as CFData,
      nil
    )
    XCTAssertTrue(isSignatureValid, "Signature should be valid")
  }
  
  func testVerify_withInvalidKey_shouldBeInvalid() {
    let dataToSign = "data".data(using: .utf8)!
    var firstPair: KeyPair!
    var secondPair: KeyPair!
    var signature: Data!
    
    XCTAssertNoThrow(firstPair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    XCTAssertNoThrow(secondPair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    
    guard let cfSignature = SecKeyCreateSignature(firstPair.privateKey, Constants.algorithm, dataToSign as CFData, nil) else {
      XCTFail()
      return
    }
    signature = cfSignature as Data
    
    let isSignatureValid = keychain.verify(withPublicKey: secondPair.publicKey, algorithm: Constants.algorithm, signedData: dataToSign, signature: signature)
    XCTAssertFalse(isSignatureValid, "Signature should be invalid")
  }
  
  func testVerify_withInvalidAlgorithm_shouldBeInvalid() {
    let dataToSign = "data".data(using: .utf8)!
    var pair: KeyPair!
    var signature: Data!
    
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    
    guard let cfSignature = SecKeyCreateSignature(pair.privateKey, Constants.algorithm, dataToSign as CFData, nil) else {
      XCTFail()
      return
    }
    signature = cfSignature as Data
    
    let isSignatureValid = keychain.verify(withPublicKey: pair.publicKey, algorithm: .ecdsaSignatureMessageX962SHA1, signedData: dataToSign, signature: signature)
    XCTAssertFalse(isSignatureValid, "Signature should be invalid")
  }
  
  func testVerify_withValidParameters_shouldBeValid() {
    let dataToSign = "data".data(using: .utf8)!
    var pair: KeyPair!
    var signature: Data!
    
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    
    guard let cfSignature = SecKeyCreateSignature(pair.privateKey, Constants.algorithm, dataToSign as CFData, nil) else {
      XCTFail()
      return
    }
    signature = cfSignature as Data
    
    let isSignatureValid = keychain.verify(withPublicKey: pair.publicKey, algorithm: Constants.algorithm, signedData: dataToSign, signature: signature)
    XCTAssertTrue(isSignatureValid, "Signature should be valid")
  }
  
  func testRepresentation_withValidKey_shouldReturnRepresentation() throws {
    var pair: KeyPair!
    var keyRepresentation: Data!
    var cfExpectedKeyRepresentation: CFData!
    
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    XCTAssertNoThrow(
      cfExpectedKeyRepresentation = SecKeyCopyExternalRepresentation(pair.publicKey, nil),
      "Expected representation should not throw"
    )
    XCTAssertNoThrow(
      keyRepresentation = try keychain.representation(forKey: pair.publicKey),
      "Keychain representation should not throw"
    )
    let expectedKeyRepresentation = cfExpectedKeyRepresentation as Data
    XCTAssertEqual(
      keyRepresentation,
      expectedKeyRepresentation,
      "Key representation should be \(expectedKeyRepresentation) but was \(keyRepresentation!)"
    )
  }
  
  func testGenerateKeyPair_withInvalidParameters_shouldThrow() {
    let expectedErrorCode = -4
    let expectedLocalizedDescription = "Invalid status code operation received: -4"

    XCTAssertThrowsError(
      try keychain.generateKeyPair(withParameters: [:]),
      "Generate KeyPair Should throw"
    ) { error in

      guard let thrownError = error as? KeychainError,
              case .invalidStatusCode(let code) = thrownError else {
        XCTFail("Unexpected error received")
        return
      }

      XCTAssertEqual(
        code,
        expectedErrorCode,
        "Error code should be \(expectedErrorCode), but was \(code)"
      )
      
      XCTAssertEqual(
        thrownError.domain,
        NSOSStatusErrorDomain,
        "Error domain should be \(NSOSStatusErrorDomain), but was \(thrownError.domain)"
      )
      
      XCTAssertEqual(
        thrownError.localizedDescription,
        expectedLocalizedDescription,
        "Error localized description should be \(expectedLocalizedDescription), but was \(thrownError.localizedDescription)"
      )
    }
  }
  
  func testGenerateKeyPair_withValidParameters_shouldReturnKeyPair() {
    var pair: KeyPair!
    XCTAssertNoThrow(
      pair = try keychain.generateKeyPair(withParameters: KeyPairFactory.keyPairParameters()),
      "Generate KeyPair should return a KeyPair"
    )
    XCTAssertNotNil(pair, "Pair should not be nil")
  }
  
  func testCopyItemMatching_withoutMatches_shouldThrow() {
    let expectedErrorCode = -25300
    let expectedLocalizedDescription = "Invalid status code operation received: -25300"

    XCTAssertThrowsError(
      try keychain.copyItemMatching(query: Constants.keyQuery),
      "Copy Item matching should throw"
    ) { error in
      guard let thrownError = error as? KeychainError,
            case .invalidStatusCode(let code) = thrownError else {
        XCTFail("Unexpected error received")
        return
      }

      XCTAssertEqual(
        code,
        expectedErrorCode,
        "Error code should be \(expectedErrorCode), but was \(code)"
      )
      
      XCTAssertEqual(
        thrownError.domain,
        NSOSStatusErrorDomain,
        "Error domain should be \(NSOSStatusErrorDomain), but was \(thrownError.domain)"
      )
      
      XCTAssertEqual(
        thrownError.localizedDescription,
        expectedLocalizedDescription,
        "Error localized description should be \(expectedLocalizedDescription), but was \(thrownError.localizedDescription)"
      )
    }
  }
  
  func testCopyItemMatching_withWrongQueryButItemExists_shouldThrow() {
    let expectedErrorCode = -25300
    let expectedLocalizedDescription = "Invalid status code operation received: -25300"
    let data = "data".data(using: .utf8)!
    let query = KeychainQuery(accessGroup: nil).save(data: data, withKey: Constants.alias, withServiceName: Constants.service)
    let status = keychain.addItem(withQuery: query)

    XCTAssertEqual(status, errSecSuccess, "Adding an item should succeed")

    XCTAssertThrowsError(
      try keychain.copyItemMatching(query: Constants.keyQuery),
      "Copy Item matching should throw"
    ) { error in
      guard let thrownError = error as? KeychainError,
            case .invalidStatusCode(let code) = thrownError else {
        XCTFail("Unexpected error received")
        return
      }

      XCTAssertEqual(
        code,
        expectedErrorCode,
        "Error code should be \(expectedErrorCode), but was \(code)"
      )
      
      XCTAssertEqual(
        thrownError.domain,
        NSOSStatusErrorDomain,
        "Error domain should be \(NSOSStatusErrorDomain), but was \(thrownError.domain)"
      )

      XCTAssertEqual(
        thrownError.localizedDescription,
        expectedLocalizedDescription,
        "Error localized description should be \(expectedLocalizedDescription), but was \(thrownError.localizedDescription)"
      )
    }
  }
    
  func testCopyItemMatching_witMatches_shouldReturnKey() {
    var pair: KeyPair!
    var keyObject: AnyObject!
    var query = Constants.saveKeyQuery
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    query[kSecValueRef] = pair.publicKey
    var status = SecItemAdd(query as CFDictionary, nil)
    XCTAssertEqual(status, errSecSuccess, "Adding an item should succeed")
    XCTAssertNoThrow(keyObject = try keychain.copyItemMatching(query: Constants.keyQuery), "Copy Item matching should return a key")
    let key = keyObject as! SecKey
    XCTAssertEqual(key, pair.publicKey, "Key should be \(pair.publicKey) but was \(key)")
    status = SecItemDelete(Constants.keyQuery as CFDictionary)
    XCTAssertEqual(status, errSecSuccess, "Adding an item should succeed")
  }
  
  func testAddItem_withInvalidArguments_shouldFail() {
    let status = keychain.addItem(withQuery: [:])
    XCTAssertEqual(status, -50)
  }
  
  func testAddItem_withValidArguments_shouldSucceed() {
    let status = keychain.addItem(withQuery: Constants.saveKeyQuery)
    XCTAssertEqual(status, errSecSuccess)
  }
  
  func testDeleteItem_withInvalidArguments_shouldFail() {
    let status = keychain.deleteItem(withQuery: [:])
    XCTAssertEqual(status, -50)
  }
  
  func testDeleteItem_withValidArguments_shouldSucceed() {
    var pair: KeyPair!
    var query = Constants.saveKeyQuery
    XCTAssertNoThrow(pair = try KeyPairFactory.createKeyPair(), "Pair generation should succeed")
    query[kSecValueRef] = pair.publicKey
    SecItemAdd(query as CFDictionary, nil)
    let status = keychain.deleteItem(withQuery: Constants.keyQuery)
    XCTAssertEqual(status, errSecSuccess)
  }

  func testCreateQuery_withAuthenticationPromt_shouldBeCreated_withGivenProperties() {
    let testKey = "test_key"
    let authenticationPromptTestKey = "authentication_prompt"
    
    let query = KeychainQuery(accessGroup: nil).getData(
      withKey: testKey,
      authenticationPrompt: authenticationPromptTestKey
    )
    
    let status = keychain.addItem(withQuery: query)
    
    XCTAssertNoThrow(query)
    XCTAssertEqual(status, errSecSuccess)
  }
}

private extension KeychainTests {
  struct Constants {
    static let alias = "alias"
    static let service = "service"
    static let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256
    static let keyQuery = [kSecClass: kSecClassKey,
                           kSecAttrKeyClass: kSecAttrKeyClassPublic,
                           kSecAttrLabel: Constants.alias,
                           kSecReturnRef: true,
                           kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                           kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
    static let saveKeyQuery = [kSecClass: kSecClassKey,
                               kSecAttrLabel: Constants.alias,
                               kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func clearKeychain() {
    let secItemClasses = [kSecClassGenericPassword,
                          kSecClassInternetPassword,
                          kSecClassCertificate,
                          kSecClassKey,
                          kSecClassIdentity]
    secItemClasses.forEach {
      SecItemDelete([kSecClass: $0] as CFDictionary)
    }
  }
}

extension CFString {
  var asString: String {
    self as String
  }
}
