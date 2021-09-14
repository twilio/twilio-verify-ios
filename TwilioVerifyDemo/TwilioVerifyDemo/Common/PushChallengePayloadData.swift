//
//  PushChallengePayloadData.swift
//  TwilioVerifyDemo
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

import Foundation

/**
 This model is intended to parse the payload data from the remote Push Notification and improve the local handling of the data.
 Please notice that this is not required in your implementation.
 */
struct PushChallengePayloadData {
  let challengeSid: String
  let factorSid: String
  let type: String
  
  private let verifyPushChallengeKey = "verify_push_challenge"

  private struct Keys {
    static let challengeSid = "challenge_sid"
    static let factorSid = "factor_sid"
    static let type = "type"
  }

  init?(payload: [String: Any]) {
    guard let challengeSid = payload[Keys.challengeSid] as? String,
          let factorSid = payload[Keys.factorSid] as? String,
          let type = payload[Keys.type] as? String,
          type == verifyPushChallengeKey else {
      return nil
    }
    
    self.challengeSid = challengeSid
    self.factorSid = factorSid
    self.type = type
  }
}
