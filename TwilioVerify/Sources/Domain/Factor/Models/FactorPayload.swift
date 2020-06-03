//
//  FactorPayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol FactorPayload {
  var friendlyName: String { get }
  var type: FactorType { get }
  var serviceSid: String { get }
  var entity: String { get }
  var config: [String: String] { get }
}

struct CreateFactorPayload: FactorPayload {
  let friendlyName: String
  let type: FactorType
  let serviceSid: String
  let entity: String
  let config: [String: String]
  let binding: [String: String]
  let jwt: String
}

struct UpdateFactorPayload: FactorPayload {
  let friendlyName: String
  let type: FactorType
  let serviceSid: String
  let entity: String
  let config: [String: String]
  let factorSid: String
}
