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
  var type: FactorType = .push
  var allowIphoneMigration: Bool = false
  let createdAt: Date
  let config: Config
  var keyPairAlias: String?
  var metadata: [String: String]?

  init(
    status: FactorStatus = .unverified,
    sid: String,
    friendlyName: String,
    accountSid: String,
    serviceSid: String,
    identity: String,
    type: FactorType = .push,
    allowIphoneMigration: Bool = false,
    createdAt: Date,
    config: Config,
    keyPairAlias: String? = nil,
    metadata: [String : String]? = nil
  ) {
    self.status = status
    self.sid = sid
    self.friendlyName = friendlyName
    self.accountSid = accountSid
    self.serviceSid = serviceSid
    self.identity = identity
    self.type = type
    self.allowIphoneMigration = allowIphoneMigration
    self.createdAt = createdAt
    self.config = config
    self.keyPairAlias = keyPairAlias
    self.metadata = metadata
  }

  enum CodingKeys: CodingKey {
    case status
    case sid
    case friendlyName
    case accountSid
    case serviceSid
    case identity
    case type
    case allowIphoneMigration
    case createdAt
    case config
    case keyPairAlias
    case metadata
  }

  init(from decoder: Decoder) throws {
    let container: KeyedDecodingContainer<PushFactor.CodingKeys> = try decoder.container(keyedBy: PushFactor.CodingKeys.self)
    self.status = try container.decode(FactorStatus.self, forKey: PushFactor.CodingKeys.status)
    self.sid = try container.decode(String.self, forKey: PushFactor.CodingKeys.sid)
    self.friendlyName = try container.decode(String.self, forKey: PushFactor.CodingKeys.friendlyName)
    self.accountSid = try container.decode(String.self, forKey: PushFactor.CodingKeys.accountSid)
    self.serviceSid = try container.decode(String.self, forKey: PushFactor.CodingKeys.serviceSid)
    self.identity = try container.decode(String.self, forKey: PushFactor.CodingKeys.identity)
    self.type = try container.decodeIfPresent(FactorType.self, forKey: PushFactor.CodingKeys.type) ?? .push
    self.allowIphoneMigration = try container.decodeIfPresent(Bool.self, forKey: PushFactor.CodingKeys.allowIphoneMigration) ?? false
    self.createdAt = try container.decode(Date.self, forKey: PushFactor.CodingKeys.createdAt)
    self.config = try container.decode(Config.self, forKey: PushFactor.CodingKeys.config)
    self.keyPairAlias = try container.decodeIfPresent(String.self, forKey: PushFactor.CodingKeys.keyPairAlias)
    self.metadata = try container.decodeIfPresent([String : String].self, forKey: PushFactor.CodingKeys.metadata)

  }

  func encode(to encoder: Encoder) throws {
    var container: KeyedEncodingContainer<PushFactor.CodingKeys> = encoder.container(keyedBy: PushFactor.CodingKeys.self)
    try container.encode(self.status, forKey: PushFactor.CodingKeys.status)
    try container.encode(self.sid, forKey: PushFactor.CodingKeys.sid)
    try container.encode(self.friendlyName, forKey: PushFactor.CodingKeys.friendlyName)
    try container.encode(self.accountSid, forKey: PushFactor.CodingKeys.accountSid)
    try container.encode(self.serviceSid, forKey: PushFactor.CodingKeys.serviceSid)
    try container.encode(self.identity, forKey: PushFactor.CodingKeys.identity)
    try container.encode(self.type, forKey: PushFactor.CodingKeys.type)
    try container.encode(self.allowIphoneMigration, forKey: PushFactor.CodingKeys.allowIphoneMigration)
    try container.encode(self.createdAt, forKey: PushFactor.CodingKeys.createdAt)
    try container.encode(self.config, forKey: PushFactor.CodingKeys.config)
    try container.encodeIfPresent(self.keyPairAlias, forKey: PushFactor.CodingKeys.keyPairAlias)
    try container.encodeIfPresent(self.metadata, forKey: PushFactor.CodingKeys.metadata)
  }
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
