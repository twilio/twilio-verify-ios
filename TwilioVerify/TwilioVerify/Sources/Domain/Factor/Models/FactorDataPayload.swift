//
//  FactorPayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol FactorDataPayload {
  var friendlyName: String { get }
  var type: FactorType { get }
  var serviceSid: String { get }
  var identity: String { get }
  var config: [String: String] { get }
}

struct CreateFactorPayload: FactorDataPayload {
  let friendlyName: String
  let type: FactorType
  let serviceSid: String
  let identity: String
  let config: [String: String]
  let binding: [String: String]
  let accessToken: String
}

struct UpdateFactorDataPayload: FactorDataPayload {
  let friendlyName: String
  let type: FactorType
  let serviceSid: String
  let identity: String
  let config: [String: String]
  let factorSid: String
}
