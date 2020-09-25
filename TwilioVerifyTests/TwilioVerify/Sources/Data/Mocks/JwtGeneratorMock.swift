//
//  JwtGeneratorMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import XCTest
@testable import TwilioVerify

class JwtGeneratorMock: JwtGeneratorProtocol {
  var jwt: String!
  private(set) var header: [String: String]!
  private(set) var payload: [String: Any]!
  var error: Error?
  
  func generateJWT(forHeader header: [String: String], forPayload payload: [String: Any], withSignerTemplate signerTemplate: SignerTemplate) throws -> String {
    if let error = error {
      throw error
    }
    self.header = header
    self.payload = payload
    return jwt!
  }
}
