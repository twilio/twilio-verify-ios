//
//  AuthenticationProviderTests.swift
//  TwilioVerifyTests
//
//  Created by Yeimi Moreno on 6/8/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class AuthenticationProviderTests: XCTestCase {
  
  var jwtGenerator: JwtGeneratorMock!
  var authenticationProvider: AuthenticationProvider!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    jwtGenerator = JwtGeneratorMock()
    authenticationProvider = AuthenticationProvider(withJwtGenerator: jwtGenerator)
  }
  
  func testGenerateJWT_withFactor_shouldReturnExpectedJWT() {
    var jwt: String!
    let expectedJWT = "expectedJWT"
    jwtGenerator.jwt = expectedJWT
    let factor = PushFactor(status: .verified, sid: "sid", friendlyName: "friendlyName", accountSid: "accountSid", serviceSid: "serviceSid", entityIdentity: "entityIdentity", createdAt: Date(), config: Config(credentialSid: "credentialSid"), keyPairAlias: "keyPairAlias")
    XCTAssertNoThrow(jwt = try authenticationProvider.generateJWT(forFactor: factor), "Generate JWT should not throw")
    XCTAssertEqual(expectedJWT, jwt, "JWT should be \(expectedJWT) but was \(String(describing: jwt))")
    XCTAssertEqual(factor.config.credentialSid, jwtGenerator.header![AuthenticationProvider.Constants.kidKey],
                   "Credential sid should be \(factor.config.credentialSid) but was \(String(describing: jwtGenerator.header![AuthenticationProvider.Constants.kidKey]))")
    XCTAssertEqual(factor.accountSid, jwtGenerator.payload![AuthenticationProvider.Constants.subKey] as! String,
                   "Account sid should be \(factor.accountSid) but was \(String(describing: jwtGenerator.payload![AuthenticationProvider.Constants.subKey]))")
    let iat = jwtGenerator.payload![AuthenticationProvider.Constants.iatKey] as! Double
    let exp = jwtGenerator.payload![AuthenticationProvider.Constants.expKey] as! Double
    let validFor = exp - iat
    XCTAssertEqual(AuthenticationProvider.Constants.jwtValidFor, validFor, "Valid for should be \(AuthenticationProvider.Constants.jwtValidFor) but was \(validFor)")
  }
  
  func testGenerateJWT_withFactorAndNoKeyPair_shouldThrow() {
    let factor = PushFactor(status: .verified, sid: "sid", friendlyName: "friendlyName", accountSid: "accountSid", serviceSid: "serviceSid", entityIdentity: "entityIdentity", createdAt: Date(), config: Config(credentialSid: "credentialSid"), keyPairAlias: nil)
    XCTAssertThrowsError(try authenticationProvider.generateJWT(forFactor: factor), "Generate JWT should throw") { error in
      XCTAssertEqual((error as! TwilioVerifyError).originalError, AuthenticationError.invalidKeyPair as NSError)
      XCTAssertEqual(((error as! TwilioVerifyError).originalError as? AuthenticationError)!.errorDescription, AuthenticationError.invalidKeyPair.errorDescription)
    }
  }
  
  func testGenerateJWT_withNoSupportedFactor_shouldThrow() {
    let factor = FactorMock(status: .unverified, sid: "sid", friendlyName: "friendlyName", accountSid: "accountSid", serviceSid: "serviceSid", entityIdentity: "entityIdentity", type: .push, createdAt: Date())
    XCTAssertThrowsError(try authenticationProvider.generateJWT(forFactor: factor), "Generate JWT should throw") { error in
      XCTAssertEqual((error as! TwilioVerifyError).originalError, AuthenticationError.invalidFactor as NSError)
      XCTAssertEqual(((error as! TwilioVerifyError).originalError as? AuthenticationError)!.errorDescription, AuthenticationError.invalidFactor.errorDescription)
    }
  }
}

private struct FactorMock: Factor {
  let status: FactorStatus
  let sid: String
  let friendlyName: String
  let accountSid: String
  let serviceSid: String
  let entityIdentity: String
  let type: FactorType
  let createdAt: Date
}
