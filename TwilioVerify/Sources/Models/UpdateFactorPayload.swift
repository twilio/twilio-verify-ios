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

struct UpdatePushFactorPayload: UpdateFactorPayload {
  let sid: String
  let pushToken: String
}
