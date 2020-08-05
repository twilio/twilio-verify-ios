//
//  ChallengeListPayload.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

///Describes the information required to fetch a **ChallengeList**
public struct ChallengeListPayload {
  ///Sid of the factor to which the Challenge is related
  public let factorSid: String
  ///Number of Challenges to be returned by the service
  public let pageSize: Int
  ///Status to filter the Challenges, if nothing is sent, Challenges of all status will be returned
  public var status: ChallengeStatus? = nil
  ///
  public var pageToken: String? = nil
  
  /**
  Creates a **ChallengeListPayload** with the given parameters
  - Parameters:
    - factorSid: Sid of the factor to which the Challenge is related
    - pageSize: Number of Challenges to be returned by the service
    - status: Status to filter the Challenges, if nothing is sent, Challenges of all status will be
              returned
    - pageToken:
  */
  public init(factorSid: String, pageSize: Int, status: ChallengeStatus? = nil, pageToken: String? = nil) {
    self.factorSid = factorSid
    self.pageSize = pageSize
    self.status = status
    self.pageToken = pageToken
  }
}
