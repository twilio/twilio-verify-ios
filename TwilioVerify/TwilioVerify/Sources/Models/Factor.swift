//
//  Factor.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

///Describes the information of a **Factor**.
public protocol Factor {
  ///Status of the Factor.
  var status: FactorStatus { get set }
  ///The unique SID identifier of the Factor.
  var sid: String { get }
  ///A human readable description of this resource, up to 64 characters. For a push factor, this can be the device's name.
  var friendlyName: String { get }
  ///The unique SID of the Account that created the Service resource.
  var accountSid: String { get }
  ///The unique SID identifier of the Service to which the Factor is related.
  var serviceSid: String { get }
  ///Identifies the user, should be an UUID you should not use PII (Personal Identifiable Information)
  ///because the systems that will process this attribute assume it is not directly identifying information.
  var identity: String { get }
  ///Type of the Factor. Currently only `push` is supported.
  var type: FactorType { get }
  ///Indicates the creation date of the Factor.
  var createdAt: Date { get }
}

///Describes the verification status of a Factor.
public enum FactorStatus: String, Codable {
  ///The Factor is verified and is ready to recevie challenges.
  case verified
  ///The Factor is not yet verified and can't receive challenges.
  case unverified
}

///Describes the types a factor can have.
public enum FactorType: String, Codable {
  ///Push type.
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
