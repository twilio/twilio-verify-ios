//
//  FakeFactorPayload.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
