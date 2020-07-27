//
//  UpdateFactorPayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol UpdateFactorPayload {
  var sid: String { get }
}

public struct UpdatePushFactorPayload: UpdateFactorPayload {
  public let sid: String
  public let pushToken: String
  
  public init(sid: String, pushToken: String) {
    self.sid = sid
    self.pushToken = pushToken
  }
}
