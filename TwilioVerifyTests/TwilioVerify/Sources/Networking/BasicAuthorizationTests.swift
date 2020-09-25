//
//  BasicAuthorizationTests.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import XCTest
@testable import TwilioVerify

class BasicAuthorizationTests: XCTestCase {
  
  func testAuthorization_withBasicAuthorization_shouldReturnExpectedHeader() {
    let expectedBasicAuthorization = "\(HTTPHeader.Constant.basic) dXNlcm5hbWU6cGFzc3dvcmQ="
    let authorization = BasicAuthorization(username: "username", password: "password")
    XCTAssertEqual(authorization.header().value, expectedBasicAuthorization,
                   "Basic authorization should be \(expectedBasicAuthorization) but was \(authorization.header().value)")
  }
}
