//
//  JwtGeneratorMock.swift
//  TwilioVerifyTests
//
//  Created by Yeimi Moreno on 6/8/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify
import TwilioSecurity

class JwtGeneratorMock: JwtGeneratorProtocol {
  var jwt: String!
  private(set) var header: [String: String]!
  private(set) var payload: [String: Any]!
  
  func generateJWT(forHeader header: [String: String], forPayload payload: [String: Any], withSignerTemplate signerTemplate: SignerTemplate) throws -> String {
    self.header = header
    self.payload = payload
    return jwt!
  }
}
