//
//  VerifyFactorPayload.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

///Describes the information required to verify a **Factor**
public protocol VerifyFactorPayload {
  /// Factor sid
  var sid: String { get }
}

///Describes the information required to verify a **Factor** which type is **Push**
public struct VerifyPushFactorPayload: VerifyFactorPayload {
  /// Factor sid
  public let sid: String
  
  /**
  Creates a **VerifyPushFactorPayload** with the given parameters
  - Parameters:
    - sid: Factor sid
  */
  public init(sid: String) {
    self.sid = sid
  }
}
