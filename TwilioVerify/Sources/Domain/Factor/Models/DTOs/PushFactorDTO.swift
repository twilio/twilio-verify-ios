//
//  PushFactorDTO.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/5/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct PushFactorDTO: Codable {
  var status: FactorStatus
  let sid: String
  let friendlyName: String
  let accountSid: String
  var createdAt: String
  let config: ConfigDTO
}

extension PushFactorDTO {
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
}

extension ConfigDTO {
  enum CodingKeys: String, CodingKey {
    case credentialSid = "credential_sid"
  }
}
