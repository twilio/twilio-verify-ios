//
//  VerifyFactorPayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol VerifyFactorPayload {
  var sid: String { get }
}

public struct VerifyPushFactorPayload: VerifyFactorPayload {
  public let sid: String
  
  public init(sid: String) {
    self.sid = sid
  }
}
