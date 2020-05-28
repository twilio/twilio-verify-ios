//
//  KeychainTests.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioSecurity

class KeychainTests: XCTestCase {
  
  var keychain: KeychainProtocol!
  
  override func setUpWithError() throws {
    keychain = Keychain()
  }
  
  func testAccessControl_withInvalidProtection_shouldThrow() {
    let expectedErrorCode = -50
    let expectedErrorDomain = "NSOSStatusErrorDomain"
    let expectedLocalizedDescription = "The operation couldn’t be completed. (OSStatus error -50 - SecAccessControl: invalid protection: )"
    XCTAssertThrowsError(try keychain.accessControl(withProtection: String() as CFString), "Access Control sohuld throw", { error in
      let thrownError = error as NSError
      XCTAssertEqual(
        thrownError.code,
        expectedErrorCode,
        "Error code should be \(expectedErrorCode), but was \(thrownError.code)"
      )
      XCTAssertEqual(
        thrownError.domain,
        expectedErrorDomain,
        "Error domain should be \(expectedErrorDomain), but was \(thrownError.domain)"
      )
      XCTAssertEqual(
        thrownError.localizedDescription,
        expectedLocalizedDescription,
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
    let expectedLocalizedDescription = "The operation couldn’t be completed. (OSStatus error -50 - bad digest size for signing with algorithm algid:sign:ECDSA:digest-X962:SHA256)"
    let dataToSign = "data".data(using: .utf8)!
    var publicKey: SecKey?
    var privateKey: SecKey?
    let status = SecKeyGeneratePair(Constants.pairAttributes as CFDictionary, &publicKey, &privateKey)
    
    XCTAssertEqual(status, errSecSuccess, "Pair generation should succeed")
    XCTAssertThrowsError(try keychain.sign(withPrivateKey: privateKey!, algorithm: .ecdsaSignatureDigestX962SHA256, dataToSign: dataToSign), "") { error in
      let thrownError = error as NSError
      XCTAssertEqual(
        thrownError.code,
        expectedErrorCode,
        "Error code should be \(expectedErrorCode), but was \(thrownError.code)"
      )
      XCTAssertEqual(
        thrownError.domain,
        expectedErrorDomain,
        "Error domain should be \(expectedErrorDomain), but was \(thrownError.domain)"
      )
      XCTAssertEqual(
        thrownError.localizedDescription,
        expectedLocalizedDescription,
        "Error localized description should be \(expectedLocalizedDescription), but was \(thrownError.localizedDescription)"
      )
    }
  }
  
  func testSign_withValidAlgorithm_shouldReturnSignature() {
    let dataToSign = "data".data(using: .utf8)!
    var publicKey: SecKey?
    var privateKey: SecKey?
    var signature: Data!
    
    let status = SecKeyGeneratePair(Constants.pairAttributes as CFDictionary, &publicKey, &privateKey)
    XCTAssertEqual(status, errSecSuccess, "Pair generation should succeed")
    XCTAssertNoThrow(signature = try keychain.sign(withPrivateKey: privateKey!, algorithm: Constants.algorithm, dataToSign: dataToSign), "Sign should not throw")
    
    let isSignatureValid = SecKeyVerifySignature(
      publicKey!,
      .ecdsaSignatureMessageX962SHA256,
      dataToSign as CFData,
      signature as CFData,
      nil
    )
    XCTAssertTrue(isSignatureValid, "Signature should be valid")
  }
  
  func testVerify_withInvalidKey_shouldBeInvalid() {
    let dataToSign = "data".data(using: .utf8)!
    var firstPublicKey: SecKey?
    var firstPrivateKey: SecKey?
    var secondPublicKey: SecKey?
    var secondPrivateKey: SecKey?
    var signature: Data!
    
    let firstPairStatus = SecKeyGeneratePair(Constants.pairAttributes as CFDictionary, &firstPublicKey, &firstPrivateKey)
    let secondPairStatus = SecKeyGeneratePair(Constants.pairAttributes as CFDictionary, &secondPublicKey, &secondPrivateKey)
    XCTAssertEqual(firstPairStatus, errSecSuccess, "Pair generation should succeed")
    XCTAssertEqual(secondPairStatus, errSecSuccess, "Pair generation should succeed")
    
    guard let cfSignature = SecKeyCreateSignature(firstPrivateKey!, Constants.algorithm, dataToSign as CFData, nil) else {
      XCTFail()
      return
    }
    signature = cfSignature as Data
    
    let isSignatureValid = keychain.verify(withPublicKey: secondPublicKey!, algorithm: Constants.algorithm, signedData: dataToSign, signature: signature)
    XCTAssertFalse(isSignatureValid, "Signature should be invalid")
  }
  
  func testVerify_withInvalidAlgorithm_shouldBeInvalid() {
    let dataToSign = "data".data(using: .utf8)!
    var publicKey: SecKey?
    var privateKey: SecKey?
    var signature: Data!
    
    let status = SecKeyGeneratePair(Constants.pairAttributes as CFDictionary, &publicKey, &privateKey)
    XCTAssertEqual(status, errSecSuccess, "Pair generation should succeed")
    
    guard let cfSignature = SecKeyCreateSignature(privateKey!, Constants.algorithm, dataToSign as CFData, nil) else {
      XCTFail()
      return
    }
    signature = cfSignature as Data
    
    let isSignatureValid = keychain.verify(withPublicKey: publicKey!, algorithm: .ecdsaSignatureMessageX962SHA1, signedData: dataToSign, signature: signature)
    XCTAssertFalse(isSignatureValid, "Signature should be invalid")
  }
  
  func testVerify_withValidParameters_shouldBeValid() {
    let dataToSign = "data".data(using: .utf8)!
    var publicKey: SecKey?
    var privateKey: SecKey?
    var signature: Data!
    
    let status = SecKeyGeneratePair(Constants.pairAttributes as CFDictionary, &publicKey, &privateKey)
    XCTAssertEqual(status, errSecSuccess, "Pair generation should succeed")
    
    guard let cfSignature = SecKeyCreateSignature(privateKey!, Constants.algorithm, dataToSign as CFData, nil) else {
      XCTFail()
      return
    }
    signature = cfSignature as Data
    
    let isSignatureValid = keychain.verify(withPublicKey: publicKey!, algorithm: Constants.algorithm, signedData: dataToSign, signature: signature)
    XCTAssertTrue(isSignatureValid, "Signature should be valid")
  }
  
  func testRepresentation_withValidKey_shouldReturnRepresentation() throws {
    var publicKey: SecKey?
    var privateKey: SecKey?
    var keyRepresentation: Data!
    var cfExpectedKeyRepresentation: CFData!
    
    let status = SecKeyGeneratePair(Constants.pairAttributes as CFDictionary, &publicKey, &privateKey)
    XCTAssertEqual(status, errSecSuccess, "Pair generation should succeed")
    XCTAssertNoThrow(
      cfExpectedKeyRepresentation = SecKeyCopyExternalRepresentation(publicKey!, nil),
      "Expected representation should not throw"
    )
    XCTAssertNoThrow(
      keyRepresentation = try keychain.representation(forKey: publicKey!),
      "Keychain representation should not throw"
    )
    let expectedKeyRepresentation = cfExpectedKeyRepresentation as Data
    XCTAssertEqual(
      keyRepresentation,
      expectedKeyRepresentation,
      "Key representation should be \(expectedKeyRepresentation) but was \(keyRepresentation!)"
    )
  }
}

private extension KeychainTests {
  struct Constants {
    static let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256
    static let applicationTag = "com.security.tests"
    static let publicTag = "public"
    static let privateTag = "private"
    static let privateAttributes = [kSecAttrApplicationTag: Constants.applicationTag + Constants.privateTag] as [String: Any]
    static let publicAttributes = [kSecAttrApplicationTag: Constants.applicationTag + Constants.publicTag] as [String : Any]
    static let pairAttributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                                 kSecAttrKeySizeInBits: 256,
                                 kSecPublicKeyAttrs: publicAttributes,
                                 kSecPrivateKeyAttrs: privateAttributes] as [String : Any]
  }
  

}
