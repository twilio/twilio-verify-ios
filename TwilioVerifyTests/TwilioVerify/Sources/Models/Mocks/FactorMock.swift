//
//  FactorMock.swift
//  TwilioVerifyTests
//
//  Created by Yeimi Moreno on 6/11/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

struct FactorMock: Factor {
  var status: FactorStatus
  let sid: String
  let friendlyName: String
  let accountSid: String
  let serviceSid: String
  let entityIdentity: String
  let type: FactorType
  let createdAt: Date
}
