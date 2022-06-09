//
//  PushFactor.swift
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

struct PushFactor: Factor, Codable {
  var status: FactorStatus = .unverified
  let sid: String
  let friendlyName: String
  let accountSid: String
  let serviceSid: String
  let identity: String
  let type: FactorType = .push
  let createdAt: Date
  let config: Config
  var keyPairAlias: String?
  var metadata: [String: String]?
}

struct Config: Codable {
  let credentialSid: String
  let notificationPlatform: NotificationPlatform
  
  enum CodingKeys: String, CodingKey {
    case credentialSid
    case notificationPlatform
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.credentialSid = try container.decode(String.self, forKey: .credentialSid)
    self.notificationPlatform = try container.decodeIfPresent(NotificationPlatform.self, forKey: .notificationPlatform) ?? .apn
  }
  
  init(credentialSid: String, notificationPlatform: NotificationPlatform = .apn) {
    self.credentialSid = credentialSid
    self.notificationPlatform = notificationPlatform
  }
}

public enum NotificationPlatform: String, Codable {
  case apn
  case none
}
