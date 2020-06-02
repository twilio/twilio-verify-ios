//
//  UpdateFactorPayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct UpdateFactorPayload: FactorPayload {
  let friendlyName: String
  let type: FactorType
  let serviceSid: String
  let entity: String
  let config: [String: String]
  let factorSid: String
  
  init(friendlyName: String, type: FactorType, serviceSid: String, entity: String,
       config: [String: String], factorSid: String) {
    self.friendlyName = friendlyName
    self.type = type
    self.serviceSid = serviceSid
    self.entity = entity
    self.config = config
    self.factorSid = factorSid
  }
}
