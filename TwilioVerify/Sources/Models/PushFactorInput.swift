//
//  PushFactorInput.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct PushFactorInput: FactorInput {
  let friendlyName: String
  let serviceSid: String
  let identity: String
  let factorType: FactorType = .push
  let pushToken: String
  let jwt: String
}
