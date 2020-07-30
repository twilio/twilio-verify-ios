//
//  FactorPayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol FactorPayload {
  var friendlyName: String { get }
  var serviceSid: String { get }
  var identity: String { get }
  var factorType: FactorType { get }
}

public struct PushFactorPayload: FactorPayload {
  public let friendlyName: String
  public let serviceSid: String
  public let identity: String
  public let factorType: FactorType = .push
  public let pushToken: String
  public let accessToken: String
  
  public init(friendlyName: String, serviceSid: String, identity: String, pushToken: String, accessToken: String) {
    self.friendlyName = friendlyName
    self.serviceSid = serviceSid
    self.identity = identity
    self.pushToken = pushToken
    self.accessToken = accessToken
  }
}
