//
//  AuthenticationProviderTests.swift
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
class AuthenticationProviderTests: XCTestCase {
  
  var jwtGenerator: JwtGeneratorMock!
  var dateProvider: DateProviderMock!
  var authenticationProvider: AuthenticationProvider!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    jwtGenerator = JwtGeneratorMock()
    dateProvider = DateProviderMock()
    authenticationProvider = AuthenticationProvider(withJwtGenerator: jwtGenerator, dateProvider: dateProvider)
  }
  
  func testGenerateJWT_withFactor_shouldReturnExpectedJWT() {
    var jwt: String!
    let expectedJWT = "expectedJWT"
    jwtGenerator.jwt = expectedJWT
    let factor = PushFactor(
      status: .verified,
      sid: "sid",
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      allowIphoneMigration: false,
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"),
      keyPairAlias: "keyPairAlias")
    let expectedDate = 1595358902
    dateProvider.currentTime = expectedDate
    XCTAssertNoThrow(jwt = try authenticationProvider.generateJWT(forFactor: factor), "Generate JWT should not throw")
    XCTAssertEqual(expectedJWT, jwt, "JWT should be \(expectedJWT) but was \(String(describing: jwt))")
    XCTAssertEqual(factor.config.credentialSid, jwtGenerator.header![AuthenticationProvider.Constants.kidKey],
                   "Credential sid should be \(factor.config.credentialSid) but was \(String(describing: jwtGenerator.header![AuthenticationProvider.Constants.kidKey]))")
    XCTAssertEqual(factor.accountSid, jwtGenerator.payload![AuthenticationProvider.Constants.subKey] as! String,
                   "Account sid should be \(factor.accountSid) but was \(String(describing: jwtGenerator.payload![AuthenticationProvider.Constants.subKey]))")
    let iat = jwtGenerator.payload![AuthenticationProvider.Constants.iatKey] as! Int
    let exp = jwtGenerator.payload![AuthenticationProvider.Constants.expKey] as! Int
    XCTAssertEqual(iat, expectedDate, "iat should be \(expectedDate) but was \(iat)")
    XCTAssertEqual(exp, expectedDate + AuthenticationProvider.Constants.jwtValidFor,
                   "exp should be \(expectedDate + AuthenticationProvider.Constants.jwtValidFor) but was \(exp)")
    let validFor = exp - iat
    XCTAssertEqual(AuthenticationProvider.Constants.jwtValidFor, validFor, "Valid for should be \(AuthenticationProvider.Constants.jwtValidFor) but was \(validFor)")
  }
  
  func testGenerateJWT_withFactorAndNoKeyPair_shouldThrow() {
    let factor = PushFactor(
      status: .verified,
      sid: "sid",
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      allowIphoneMigration: false,
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"),
      keyPairAlias: nil)
    let expectedDate = 1595358902
    dateProvider.currentTime = expectedDate
    XCTAssertThrowsError(try authenticationProvider.generateJWT(forFactor: factor), "Generate JWT should throw") { error in
      XCTAssertEqual((error as! TwilioVerifyError).originalError as! AuthenticationError, AuthenticationError.invalidKeyPair)
      XCTAssertEqual(((error as! TwilioVerifyError).originalError as? AuthenticationError)!.errorDescription, AuthenticationError.invalidKeyPair.errorDescription)
    }
  }
  
  func testGenerateJWT_withNoSupportedFactor_shouldThrow() {
    let factor = FactorMock(
      status: .unverified,
      sid: "sid",
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      type: .push,
      createdAt: Date())
    XCTAssertThrowsError(try authenticationProvider.generateJWT(forFactor: factor), "Generate JWT should throw") { error in
      XCTAssertEqual((error as! TwilioVerifyError).originalError as! AuthenticationError, AuthenticationError.invalidFactor)
      XCTAssertEqual(((error as! TwilioVerifyError).originalError as? AuthenticationError)!.errorDescription, AuthenticationError.invalidFactor.errorDescription)
    }
  }
}
