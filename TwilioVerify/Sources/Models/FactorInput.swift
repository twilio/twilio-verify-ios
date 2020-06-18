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

public struct PushFactorInput: FactorInput {
  public let friendlyName: String
  public let serviceSid: String
  public let identity: String
  public let factorType: FactorType = .push
  public let pushToken: String
  public let enrollmentJwe: String
}
