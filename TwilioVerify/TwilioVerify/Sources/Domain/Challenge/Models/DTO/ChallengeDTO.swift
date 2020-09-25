//
//  ChallengeDTO.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

struct ChallengeDTO: Codable {
  let sid: String
  let details: String
  let hiddenDetails: String
  let factorSid: String
  let status: ChallengeStatus
  let expirationDate: String
  let createdAt: String
  let updateAt: String
  
  enum CodingKeys: String, CodingKey {
    case sid
    case details
    case hiddenDetails = "hidden_details"
    case factorSid = "factor_sid"
    case status
    case expirationDate = "expiration_date"
    case createdAt = "date_created"
    case updateAt = "date_updated"
  }
}

struct ChallengeDetailsDTO: Codable {
  let message: String
  let fields: [Detail]?
  let date: String?
}
