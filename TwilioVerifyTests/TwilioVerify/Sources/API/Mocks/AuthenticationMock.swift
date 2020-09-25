//
//  AuthenticationMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import XCTest
@testable import TwilioVerify

class AuthenticationMock: Authentication {
  func generateJWT(forFactor factor: Factor) -> String {
    ""
  }
}
