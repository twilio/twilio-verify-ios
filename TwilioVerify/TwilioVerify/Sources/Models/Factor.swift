//
//  Factor.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

///Describes the information of a **Factor**
public protocol Factor {
  ///Status of the Factor
  var status: FactorStatus { get set }
  ///Id of the Factor
  var sid: String { get }
  ///Friendly name of the factor, can be used for display purposes
  var friendlyName: String { get }
  ///Id of the account to which the Factor is related
  var accountSid: String { get }
  ///Id of the service to which the Factor is related
  var serviceSid: String { get }
  /// Identifies the user, should be an UUID you should not use PII (Personal Identifiable Information)
  /// because the systems that will process this attribute assume it is not directly identifying information.
  var identity: String { get }
  ///Type of the Factor
  var type: FactorType { get }
  ///Indicates the creation date of the Factor
  var createdAt: Date { get }
}

///Describes the verification status of a Factor
public enum FactorStatus: String, Codable {
  ///The Factor is verified and is ready to recevie challenges
  case verified
  ///The Factor is not yet verified and can't receive challenges
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
