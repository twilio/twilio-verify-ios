//
//  BasicAuthorizationTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/1/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class BasicAuthorizationTests: XCTestCase {
  
  func testAuthorization_withBasicAuthorization_shouldReturnExpectedHeader() {
    let expectedBasicAuthorization = "\(HTTPHeader.Constant.basic) dXNlcm5hbWU6cGFzc3dvcmQ="
    let authorization = BasicAuthorization(username: "username", password: "password")
    XCTAssertEqual(expectedBasicAuthorization, authorization.header().value,
                   "Basic authorization should be \(expectedBasicAuthorization) but was \(authorization.header().value)")
  }
}
