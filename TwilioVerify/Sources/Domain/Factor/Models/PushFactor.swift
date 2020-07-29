//
//  PushFactor.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct PushFactor: Factor, Codable {
  var status: FactorStatus = .unverified
  let sid: String
  let friendlyName: String
  let accountSid: String
  let serviceSid: String
  let entityIdentity: String
  let type: FactorType = .push
  let createdAt: Date
  let config: Config
  var keyPairAlias: String? = nil
}

struct Config: Codable {
  let credentialSid: String
}

