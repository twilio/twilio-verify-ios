//
//  ChallengeMock.swift
//  TwilioVerifyTests
//
//  Created by Yeimi Moreno on 6/24/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
