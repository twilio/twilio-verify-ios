//
//  PushFactorDTO.swift
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

struct PushFactorDTO: Codable {
  var status: FactorStatus
  let sid: String
  let friendlyName: String
  let accountSid: String
  var createdAt: String
  let config: ConfigDTO
  let metadata: [String: String]?
  
  enum CodingKeys: String, CodingKey {
    case status
    case sid
    case friendlyName = "friendly_name"
    case accountSid = "account_sid"
    case createdAt = "date_created"
    case config
    case metadata
  }
}

struct ConfigDTO: Codable {
  let credentialSid: String
  let notificationPlatform: String?
  
  enum CodingKeys: String, CodingKey {
    case credentialSid = "credential_sid"
    case notificationPlatform = "notification_platform"
  }
}
