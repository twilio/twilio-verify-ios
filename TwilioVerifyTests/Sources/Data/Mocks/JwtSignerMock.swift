//
//  JwtSignerMock.swift
//  TwilioVerifyTests
//
//  Created by Yeimi Moreno on 6/10/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify
@testable import TwilioSecurity

class JwtSignerMock {
  var operationresult: Data!
}

extension JwtSignerMock: JwtSignerProtocol {
  
  func sign(message: String, withSignerTemplate signerTemplate: SignerTemplate) -> Data {
    return operationresult
  }
}
