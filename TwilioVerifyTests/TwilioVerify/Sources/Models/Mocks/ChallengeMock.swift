//
//  ChallengeMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

struct ChallengeMock: Challenge {
  var sid: String
  var factorSid: String
  var challengeDetails: ChallengeDetails
  var hiddenDetails: String
  var status: ChallengeStatus
  var createdAt: Date
  var updatedAt: Date
  var expirationDate: Date
}
