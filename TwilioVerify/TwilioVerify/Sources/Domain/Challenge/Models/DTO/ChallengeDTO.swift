//
//  ChallengeDTO.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/24/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
