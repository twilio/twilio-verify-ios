//
//  JwtGeneratorMock.swift
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
