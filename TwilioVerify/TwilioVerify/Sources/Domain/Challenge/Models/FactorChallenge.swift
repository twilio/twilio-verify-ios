//
//  FactorChallenge.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

struct FactorChallenge: Challenge {
  let sid: String
  let challengeDetails: ChallengeDetails
  let hiddenDetails: String
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
