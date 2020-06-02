//
//  PushFactor.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct PushFactor: Factor {
  var status: FactorStatus = .unverified
  let sid: String
  let friendlyName: String
  let accountSid: String
  let serviceSid: String
  let entityIdentity: String
  let type: FactorType = .push
  let createAt: Date
  let config: Config
  var keyPairAlias: String? = nil
  
  init(sid: String, friendlyName: String, accountSid: String, serviceSid: String, entityIdentity: String,
       createAt: Date, config: Config) {
    self.sid = sid
    self.friendlyName = friendlyName
    self.accountSid = accountSid
    self.serviceSid = serviceSid
    self.entityIdentity = entityIdentity
    self.createAt = createAt
    self.config = config
  }
}

struct Config {
  let credentialSid: String
  
  init(credentialSid: String) {
    self.credentialSid = credentialSid
  }
}
