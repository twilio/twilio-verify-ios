//
//  PushFactorDTO.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

struct PushFactorDTO: Codable {
  var status: FactorStatus
  let sid: String
  let friendlyName: String
  let accountSid: String
  var createdAt: String
  let config: ConfigDTO
  
  enum CodingKeys: String, CodingKey {
    case status
    case sid
    case friendlyName = "friendly_name"
    case accountSid = "account_sid"
    case createdAt = "date_created"
    case config
  }
}

struct ConfigDTO: Codable {
  let credentialSid: String
  enum CodingKeys: String, CodingKey {
    case credentialSid = "credential_sid"
  }
}
