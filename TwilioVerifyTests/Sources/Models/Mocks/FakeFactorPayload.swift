//
//  FakeFactorPayload.swift
//  TwilioVerifyTests
//
//  Created by Santiago Avila on 6/12/20.
//  Copyright © 2020 Twilio. All rights reserved.
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

struct FakeFactor: Factor {
  var status: FactorStatus
  var sid: String
  var friendlyName: String
  var accountSid: String
  var serviceSid: String
  var entityIdentity: String
  var type: FactorType
  var createdAt: Date
}

struct FakeUpdateChallengePayload: UpdateChallengePayload {
  var factorSid: String
  var challengeSid: String
}
