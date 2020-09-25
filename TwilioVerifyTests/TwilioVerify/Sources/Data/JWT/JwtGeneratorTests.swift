//
//  JwtGeneratorTests.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import XCTest
@testable import TwilioVerify

class JwtGeneratorTests: XCTestCase {
  
  var jwtSigner: JwtSignerMock!
  var jwtGenerator: JwtGenerator!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    jwtSigner = JwtSignerMock()
    jwtGenerator = JwtGenerator(withJwtSigner: jwtSigner)
  }
  
  func testGenerateJWT_withFactor_shouldReturnExpectedJWT() {
    var signerTemplate: SignerTemplate!
    XCTAssertNoThrow(signerTemplate = try ECP256SignerTemplate(withAlias: Constants.alias, shouldExist: true), "Signer template should not throw")
    let header = [JwtGenerator.Constants.algorithmKey: JwtGenerator.Constants.defaultAlg,
                  JwtGenerator.Constants.typeKey: JwtGenerator.Constants.jwtType]
    let payload = ["sub": "sub"]
    jwtSigner.operationresult = Constants.data
    var jwt: String!
    XCTAssertNoThrow(jwt = try jwtGenerator.generateJWT(forHeader: header, forPayload: payload, withSignerTemplate: signerTemplate), "Jwt generation should not throw")
    let jwtParts = jwt.components(separatedBy: ".")
    let encodedHeader = base64UrlSafeToBase64(base64url: jwtParts[0])
    let encodedPayload = base64UrlSafeToBase64(base64url: jwtParts[1])
    let encodedSignature = base64UrlSafeToBase64(base64url: jwtParts[2])
    let decodedHeader = Data(base64Encoded: encodedHeader)!
    let decodedPayload = Data(base64Encoded: encodedPayload)!
    let signature = Data(base64Encoded: encodedSignature)!
    XCTAssertEqual(signature, Constants.data)
    XCTAssertEqual(header, try JSONSerialization.jsonObject(with: decodedHeader, options: []) as? [String: String])
    XCTAssertEqual(payload, try JSONSerialization.jsonObject(with: decodedPayload, options: []) as? [String: String])
  }
}

private extension JwtGeneratorTests {
  struct Constants {
    static let alias = "alias"
    static let data = "data".data(using: .utf8)!
  }
  
  func base64UrlSafeToBase64(base64url: String) -> String {
    var base64 = base64url.replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    if base64.count % 4 != 0 {
      base64.append(String(repeating: "=", count: 4 - base64.count % 4))
    }
    return base64
  }
}
