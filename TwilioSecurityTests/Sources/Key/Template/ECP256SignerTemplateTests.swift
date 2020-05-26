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

  private var keyManager: KeyManagerMock!
  private var keyChain: KeychainMock!
  private var signer: ECP256SignerTemplate!
  
  private let shouldExist = false
  
  override func setUpWithError() throws {
    keyManager = KeyManagerMock()
    keyChain = KeychainMock()
  }
  
  func testCreateSigner_shouldMatchExpectedParameters() {
    do {
      signer = try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: shouldExist, keychain: keyChain)
      XCTAssertEqual(Constants.alias, signer.alias, "Signer alias should be \(Constants.alias) but was \(signer.alias)")
      XCTAssertEqual(SecKeyAlgorithm.ecdsaSignatureDigestX962SHA256, signer.signatureAlgorithm,
                     "Signature algorithm should be \(SecKeyAlgorithm.ecdsaSignatureDigestX962SHA256) but was \(signer.signatureAlgorithm)")
      XCTAssertEqual(kSecAttrKeyTypeECSECPrimeRandom as String, signer.algorithm, "Algorithm should be \(kSecAttrKeyTypeECSECPrimeRandom) but was \(signer.algorithm)")
      XCTAssertEqual(kSecAttrKeyTypeECSECPrimeRandom as String, signer.parameters[kSecAttrKeyType as String] as! String,
                     "Algorithm should be \(kSecAttrKeyTypeECSECPrimeRandom) but was \(signer.parameters[kSecAttrKeyType as String] as! String)")
      XCTAssertEqual(ECP256SignerTemplate.Constants.keySize, signer.parameters[kSecAttrKeySizeInBits as String] as! Int,
                     "Key size should be \(ECP256SignerTemplate.Constants.keySize) but was \(signer.parameters[kSecAttrKeySizeInBits as String] as! Int)")
      XCTAssertEqual(kSecAttrTokenIDSecureEnclave as String, signer.parameters[kSecAttrTokenID as String] as! String,
                     "Token id should be \(kSecAttrTokenIDSecureEnclave as String) but was \(signer.parameters[kSecAttrTokenID as String] as! String)")
      let privateKeyAttrs = signer.parameters[kSecPrivateKeyAttrs as String] as! [String:Any]
      XCTAssertEqual(Constants.alias, privateKeyAttrs[kSecAttrLabel as String] as! String,
                     "Signer alias should be \(Constants.alias) but was \(privateKeyAttrs[kSecAttrLabel as String] as! String)")
      XCTAssertTrue(privateKeyAttrs[kSecAttrIsPermanent as String]! as! Bool, "Attribute is permanent should be true")
      XCTAssertEqual(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, privateKeyAttrs[kSecAttrAccessible as String] as! CFString,
                     "Attribute is accessible after first unlock should be \(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly) but was \(privateKeyAttrs[kSecAttrAccessible as String] as! CFString)")
      let publicKeyAttrs = signer.parameters[kSecPublicKeyAttrs as String] as! [String:Any]
      XCTAssertEqual(Constants.alias, publicKeyAttrs[kSecAttrLabel as String] as! String,
                     "Signer alias should be \(Constants.alias) but was \(publicKeyAttrs[kSecAttrLabel as String] as! String)")
      let expectedAccessControl = try keyChain.accessControl(withProtection: ECP256SignerTemplate.Constants.accessControlProtection, flags: [])
      XCTAssertEqual(expectedAccessControl, publicKeyAttrs[kSecAttrAccessControl as String] as! SecAccessControl,
                     "Secure Access control should be \(expectedAccessControl) but was \(publicKeyAttrs[kSecAttrAccessControl as String] as! SecAccessControl)")
    } catch let error {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCreateSigner_shouldThrowError() {
    keyChain.accessControlError = NSError(domain: "Error generating secure access control", code: -1, userInfo: nil)
    XCTAssertThrowsError(try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: shouldExist, keychain: keyChain))
  }
}

private extension ECP256SignerTemplateTests{
  struct Constants {
    static let alias = "signerAlias"
  }
}
