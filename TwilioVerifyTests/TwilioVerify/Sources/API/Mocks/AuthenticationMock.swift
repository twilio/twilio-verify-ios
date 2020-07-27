//
//  AuthenticationMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/5/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class AuthenticationMock: Authentication {
  func generateJWT(forFactor factor: Factor) -> String {
    ""
  }
}
