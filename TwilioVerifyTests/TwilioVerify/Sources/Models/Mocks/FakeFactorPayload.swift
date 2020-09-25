//
//  FakeFactorPayload.swift
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

import Foundation
@testable import TwilioVerify

struct FakeFactorPayload: FactorPayload {
  var friendlyName: String
  var serviceSid: String
  var identity: String
  var factorType: FactorType
}

struct FakeVerifyPushFactorPayload: VerifyFactorPayload {
  let sid: String
}

struct FakeUpdateFactorPayload: UpdateFactorPayload {
  let sid: String
}

struct FakeFactor: Factor {
  var status: FactorStatus
  var sid: String
  var friendlyName: String
  var accountSid: String
  var serviceSid: String
  var identity: String
  var type: FactorType
  var createdAt: Date
}

struct FakeUpdateChallengePayload: UpdateChallengePayload {
  var factorSid: String
  var challengeSid: String
}
