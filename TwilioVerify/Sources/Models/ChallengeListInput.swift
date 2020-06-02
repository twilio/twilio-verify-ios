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
  let status: ChallengeStatus?
  let pageToken: String?
  
  init(factorSid: String, pageSize: Int, status: ChallengeStatus? = nil, pageToken: String? = nil) {
    self.factorSid = factorSid
    self.pageSize = pageSize
    self.status = status
    self.pageToken = pageToken
  }
}
