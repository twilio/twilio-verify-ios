//
//  ECP256SignerTemplateTests.swift
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
class ECP256SignerTemplateTests: XCTestCase {

  private var keychain: KeychainMock!
  private var signer: SignerTemplate!
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
      if TARGET_OS_SIMULATOR == 0 {
        XCTAssertEqual(kSecAttrTokenIDSecureEnclave as String,
                       signer.parameters[kSecAttrTokenID as String] as! String,
                       "Token id should be \(kSecAttrTokenIDSecureEnclave as String) but was \(signer.parameters[kSecAttrTokenID as String] as! String)")
      } else {
        XCTAssertNil(signer.parameters[kSecAttrTokenID as String])
      }
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
