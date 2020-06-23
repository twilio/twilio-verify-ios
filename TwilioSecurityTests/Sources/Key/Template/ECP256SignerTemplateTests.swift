//
//  ECP256SignerTemplateTests.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioSecurity

class ECP256SignerTemplateTests: XCTestCase {

  private var keychain: KeychainMock!
  private var signer: ECP256SignerTemplate!
  private let shouldExist = false
  
  override func setUpWithError() throws {
    keychain = KeychainMock()
  }
  
  func testCreateSigner_shouldMatchExpectedParameters() {
      XCTAssertNoThrow(signer = try ECP256SignerTemplate(withAlias: Constants.alias,
                                                         shouldExist: shouldExist,
                                                         keychain: keychain))
      let privateKeyAttrs = signer.parameters[kSecPrivateKeyAttrs as String] as! [String: Any]
      let publicKeyAttrs = signer.parameters[kSecPublicKeyAttrs as String] as! [String: Any]
      var expectedAccessControl: SecAccessControl!
    
      XCTAssertEqual(Constants.alias,
                     signer.alias,
                     "Signer alias should be \(Constants.alias) but was \(signer.alias)")
      XCTAssertEqual(SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256,
                     signer.signatureAlgorithm,
                     "Signature algorithm should be \(SecKeyAlgorithm.ecdsaSignatureDigestX962SHA256) but was \(signer.signatureAlgorithm)")
      XCTAssertEqual(kSecAttrKeyTypeECSECPrimeRandom as String,
                     signer.algorithm,
                     "Algorithm should be \(kSecAttrKeyTypeECSECPrimeRandom) but was \(signer.algorithm)")
      XCTAssertEqual(kSecAttrKeyTypeECSECPrimeRandom as String,
                     signer.parameters[kSecAttrKeyType as String] as! String,
                     "Algorithm should be \(kSecAttrKeyTypeECSECPrimeRandom) but was \(signer.parameters[kSecAttrKeyType as String] as! String)")
      XCTAssertEqual(ECP256SignerTemplate.Constants.keySize,
                     signer.parameters[kSecAttrKeySizeInBits as String] as! Int,
                     "Key size should be \(ECP256SignerTemplate.Constants.keySize) but was \(signer.parameters[kSecAttrKeySizeInBits as String] as! Int)")
      XCTAssertEqual(kSecAttrTokenIDSecureEnclave as String,
                     signer.parameters[kSecAttrTokenID as String] as! String,
                     "Token id should be \(kSecAttrTokenIDSecureEnclave as String) but was \(signer.parameters[kSecAttrTokenID as String] as! String)")
      XCTAssertEqual(Constants.alias,
                     privateKeyAttrs[kSecAttrLabel as String] as! String,
                     "Signer alias should be \(Constants.alias) but was \(privateKeyAttrs[kSecAttrLabel as String] as! String)")
      XCTAssertTrue(privateKeyAttrs[kSecAttrIsPermanent as String]! as! Bool,
                    "Attribute is permanent should be true")
      XCTAssertEqual(Constants.alias,
                     publicKeyAttrs[kSecAttrLabel as String] as! String,
                     "Signer alias should be \(Constants.alias) but was \(publicKeyAttrs[kSecAttrLabel as String] as! String)")
      XCTAssertNoThrow(expectedAccessControl = try keychain.accessControl(withProtection: ECP256SignerTemplate.Constants.accessControlProtection,
                                                                          flags: ECP256SignerTemplate.Constants.accessControlFlags))
      XCTAssertEqual(expectedAccessControl,
                     (privateKeyAttrs[kSecAttrAccessControl as String] as! SecAccessControl),
                     "Secure Access control should be \(expectedAccessControl!) but was \(privateKeyAttrs[kSecAttrAccessControl as String] as! SecAccessControl)")
  }
  
  func testCreateSigner_shouldThrowError() {
    keychain.error = TestError.operationFailed
    XCTAssertThrowsError(try ECP256SignerTemplate(withAlias: Constants.alias,
                                                  shouldExist: shouldExist,
                                                  keychain: keychain))
  }
}

private extension ECP256SignerTemplateTests {
  struct Constants {
    static let alias = "signerAlias"
  }
}
