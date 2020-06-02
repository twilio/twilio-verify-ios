//
//  Factor.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol Factor {
  var status: FactorStatus { get }
  var sid: String { get }
  var friendlyName: String { get }
  var accountSid: String { get }
  var serviceSid: String { get }
  var entityIdentity: String { get }
  var type: FactorType { get }
  var createAt: Date { get }
}

public enum FactorStatus {
  case verified
  case unverified
}

extension FactorStatus {
  var value: String {
    switch self {
      case .verified:
        return "verified"
      case .unverified:
        return "unverified"
    }
  }
}
