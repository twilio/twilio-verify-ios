//
//  VerifyFactorInput.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol VerifyFactorInput {
  var sid: String { get }
}

public struct VerifyPushFactorInput: VerifyFactorInput {
  public let sid: String
  
  public init(sid: String) {
    self.sid = sid
  }
}
