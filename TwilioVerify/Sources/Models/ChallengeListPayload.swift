//
//  ChallengeListPayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public struct ChallengeListPayload {
  public let factorSid: String
  public let pageSize: Int
  public var status: ChallengeStatus? = nil
  public var pageToken: String? = nil
  
  public init(factorSid: String, pageSize: Int, status: ChallengeStatus? = nil, pageToken: String? = nil) {
    self.factorSid = factorSid
    self.pageSize = pageSize
    self.status = status
    self.pageToken = pageToken
  }
}
