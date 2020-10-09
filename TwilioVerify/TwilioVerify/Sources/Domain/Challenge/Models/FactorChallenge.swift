//
//  FactorChallenge.swift
//  TwilioVerify
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

import Foundation

struct FactorChallenge: Challenge {
  let sid: String
  let challengeDetails: ChallengeDetails
  let hiddenDetails: [String: String]?
  let factorSid: String
  let status: ChallengeStatus
  let createdAt: Date
  let updatedAt: Date
  let expirationDate: Date
  var factor: Factor?
  // Original values to generate signature
  var signatureFields: [String]?
  var response: [String: Any]?
}
