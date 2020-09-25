//
//  FactorMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

struct FactorMock: Factor {
  var status: FactorStatus
  let sid: String
  let friendlyName: String
  let accountSid: String
  let serviceSid: String
  let identity: String
  let type: FactorType
  let createdAt: Date
}
