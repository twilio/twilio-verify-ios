//
//  ChallengeDTO.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

struct ChallengeDTO: Codable {
  let sid: String
  let details: ChallengeDetailsDTO
  let hiddenDetails: [String: String]?
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
