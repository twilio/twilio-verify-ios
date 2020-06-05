//
//  FactorInput.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol FactorInput {
  var friendlyName: String { get }
  var serviceSid: String { get }
  var identity: String { get }
  var factorType: FactorType { get }
}

struct PushFactorInput: FactorInput {
  let friendlyName: String
  let serviceSid: String
  let identity: String
  let factorType: FactorType = .push
  let pushToken: String
  let enrollmentJwe: String
}
