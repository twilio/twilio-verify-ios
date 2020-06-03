//
//  UpdatePushFactorInput.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct UpdatePushFactorInput: UpdateFactorInput {
  let sid: String
  let pushToken: String
}
