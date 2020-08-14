//
//  VerifyFactorPayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
