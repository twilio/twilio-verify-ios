//
//  Factor.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol Factor {
  var status: FactorStatus { get set }
  var sid: String { get }
  var friendlyName: String { get }
  var accountSid: String { get }
  var serviceSid: String { get }
  var identity: String { get }
  var type: FactorType { get }
  var createdAt: Date { get }
}

///Describes the verification status of a factor
public enum FactorStatus: String, Codable {
  ///The factor is verified and is ready to recevie challenges
  case verified
  ///The factor is not yet verified and can't receive challenges
  case unverified
}

///Describes the types a factor can have
public enum FactorType: String, Codable {
  ///Push type
  case push
}

extension KeyPath where Root == Factor {
  var toString: String {
    switch self {
      case \Factor.type: return "type"
      case \Factor.status: return "status"
      default: fatalError("Unexpected key path")
    }
  }
}
