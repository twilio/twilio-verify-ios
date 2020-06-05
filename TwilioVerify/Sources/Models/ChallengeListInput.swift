//
//  ChallengeListInput.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public struct ChallengeListInput {
  let factorSid: String
  let pageSize: Int
  var status: ChallengeStatus? = nil
  var pageToken: String? = nil
}
