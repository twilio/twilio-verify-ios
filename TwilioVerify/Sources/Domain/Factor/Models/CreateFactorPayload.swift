//
//  CreateFactorPayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct CreateFactorPayload: FactorPayload {
  let friendlyName: String
  let type: FactorType
  let serviceSid: String
  let entity: String
  let config: [String : String]
  
  init(friendlyName: String, type: FactorType, serviceSid: String, entity: String,
       config: [String: String], binding: [String: String], jwt: String) {
    self.friendlyName = friendlyName
    self.type = type
    self.serviceSid = serviceSid
    self.entity = entity
    self.config = config
  }
}
