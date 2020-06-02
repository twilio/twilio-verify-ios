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
  let createAt: Date
  let updatedAt: Date
  let expirationDate: Date
  // Original values to generate signature
  let details: String
  let createdDate: String
  let updatedDate: String
  let entitySid: String
  var factor: Factor?
  
  init(sid: String, challengeDetails: ChallengeDetails, hiddenDetails: String, factorSid: String, status: ChallengeStatus,
       createAt: Date, updatedAt: Date, expirationDate: Date, details: String, createdDate: String, updatedDate: String,
       entitySid: String, factor: Factor? = nil) {
    self.sid = sid
    self.challengeDetails = challengeDetails
    self.hiddenDetails = hiddenDetails
    self.factorSid = factorSid
    self.status = status
    self.createAt = createAt
    self.updatedAt = updatedAt
    self.expirationDate = expirationDate
    self.details = details
    self.createdDate = createdDate
    self.updatedDate = updatedDate
    self.entitySid = entitySid
    self.factor = factor
  }
}
