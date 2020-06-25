//
//  FactorChallenge.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
  var factor: Factor? = nil
  // Original values to generate signature
  var signatureFields: [String]? = nil
  var response: [String: Any]? = nil
}
