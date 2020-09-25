//
//  PushFactor.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
}

struct Config: Codable {
  let credentialSid: String
}
