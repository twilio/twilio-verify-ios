//
//  UpdateChallengeInput.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol UpdateChallengeInput {
  var factorSid: String { get }
  var challengeSid: String { get }
}
