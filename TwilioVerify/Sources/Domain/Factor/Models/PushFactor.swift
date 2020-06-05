//
//  PushFactor.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct PushFactor: Factor {
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

struct Config {
  let credentialSid: String
}

