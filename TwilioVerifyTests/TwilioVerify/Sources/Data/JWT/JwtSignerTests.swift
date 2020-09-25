//
//  JwtSignerTests.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import XCTest
@testable import TwilioVerify

// swiftlint:disable force_cast
class JwtSignerTests: XCTestCase {

  var keyStorage: KeyStorageMock!
  var jwtSigner: JwtSigner!

  override func setUpWithError() throws {
    try super.setUpWithError()
    keyStorage = KeyStorageMock()
    jwtSigner = JwtSigner(withKeyStorage: keyStorage)
  }
  
  func testSign_withDERSignature_shouldReturnConcatFormat() {
    var signerTemplate: SignerTemplate!
    XCTAssertNoThrow(signerTemplate = try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: true),
                     "Signer template should not throw")
    keyStorage.signResult = Data(base64Encoded: Constants.derSignature)
    var signature: Data!
    XCTAssertNoThrow(signature = try jwtSigner.sign(message: Constants.message,
                                                    withSignerTemplate: signerTemplate), "Sign should not throw")
    XCTAssertEqual(Constants.concatSignature, signature.base64EncodedString())
  }
  
  func testSign_withInvalidDERSignature_shouldThrow() {
    var signerTemplate: SignerTemplate!
    XCTAssertNoThrow(signerTemplate = try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: true),
                     "Signer template should not throw")
    var bytes = [UInt8](repeating: 0, count: 1)
    _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    keyStorage.signResult = Data(bytes)
    XCTAssertThrowsError(try jwtSigner.sign(message: Constants.message,
                                            withSignerTemplate: signerTemplate), "Sign should not throw") { error in
                                              XCTAssertEqual((error as! JwtSignerError), JwtSignerError.invalidFormat)
    }
  }
}

private extension JwtSignerTests {
  struct Constants {
    static let alias = "alias"
    static let message = "message"
    static let derSignature = "MEQCIFtun9Ioo+W+juCG7sOl8PPPuozb8cspsUtpu2TxnzP/AiAi1VpFNTr2eK+VX3b1DLHy8rPm3MOpTvUH14hyNr0Gfg=="
    static let concatSignature = "W26f0iij5b6O4Ibuw6Xw88+6jNvxyymxS2m7ZPGfM/8i1VpFNTr2eK+VX3b1DLHy8rPm3MOpTvUH14hyNr0Gfg=="
  }
}
