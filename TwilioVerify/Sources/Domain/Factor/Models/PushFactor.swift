//
//  PushFactor.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct PushFactor: Factor, Codable {
  let status: FactorStatus
  let sid: String
  let friendlyName: String
  let accountSid: String
  var serviceSid: String
  var entityIdentity: String
  let type: FactorType = .push
  var createdAt: Date
  let config: Config
  var keyPairAlias: String? = nil
}

extension PushFactor {
  enum CodingKeys: String, CodingKey {
    case status
    case sid
    case friendlyName
    case accountSid
    case serviceSid
    case entityIdentity
    case type
    case createdAt
    case config
    case keyPairAlias
  }
}

struct Config: Codable {
  let credentialSid: String
}

