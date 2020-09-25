//
//  FactorPayload.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
