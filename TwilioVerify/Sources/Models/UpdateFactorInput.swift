//
//  UpdateFactorInput.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol UpdateFactorInput {
  var sid: String { get }
}

struct UpdatePushFactorInput: UpdateFactorInput {
  let sid: String
  let pushToken: String
}
