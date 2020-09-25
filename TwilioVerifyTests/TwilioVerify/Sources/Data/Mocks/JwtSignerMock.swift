//
//  JwtSignerMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

class JwtSignerMock {
  var operationresult: Data!
}

extension JwtSignerMock: JwtSignerProtocol {
  
  func sign(message: String, withSignerTemplate signerTemplate: SignerTemplate) -> Data {
    return operationresult
  }
}
