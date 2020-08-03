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
  ///Id of the Factor to which the Challenge is related
  var factorSid: String { get }
  ///Id of the Challenge to be updated
  var challengeSid: String { get }
}

///Describes the information required to update a **Push Challenge**
public struct UpdatePushChallengePayload: UpdateChallengePayload {
  ///Id of the Factor to which the Challenge is related
  public let factorSid: String
  ///Id of the Challenge to be updated
  public let challengeSid: String
  //New status of the Challenge
  public let status: ChallengeStatus
  
  /**
  Creates an **UpdatePushChallengePayload** with the given parameters
  - Parameters:
    - factorSid: Id of the Factor to which the Challenge is related
    - challengeSid: Id of the Challenge to be updated
    - status: New status of the Challenge
  */
  public init(factorSid: String, challengeSid: String, status: ChallengeStatus) {
    self.factorSid = factorSid
    self.challengeSid = challengeSid
    self.status = status
  }
}
