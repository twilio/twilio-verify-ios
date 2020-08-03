//
//  UpdateChallengePayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

///Describes the information required to update a **Challenge**
public protocol UpdateChallengePayload {
  var factorSid: String { get }
  var challengeSid: String { get }
}

public struct UpdatePushChallengePayload: UpdateChallengePayload {
  public let factorSid: String
  public let challengeSid: String
  public let status: ChallengeStatus
  
  public init(factorSid: String, challengeSid: String, status: ChallengeStatus) {
    self.factorSid = factorSid
    self.challengeSid = challengeSid
    self.status = status
  }
}
