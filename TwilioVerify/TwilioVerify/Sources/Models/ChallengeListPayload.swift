//
//  ChallengeListPayload.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

///Describes the information required to fetch a **ChallengeList**
public struct ChallengeListPayload {
  ///The unique SID identifier of the Factor to which the **ChallengeList** is related
  public let factorSid: String
  ///Number of Challenges to be returned by the service
  public let pageSize: Int
  ///Status to filter the Challenges, if nothing is sent, Challenges of all status will be returned
  public var status: ChallengeStatus?
  ///Token used to retrieve the next page in the pagination arrangement
  public var pageToken: String?
  
  /**
  Creates a **ChallengeListPayload** with the given parameters
  - Parameters:
    - factorSid: The unique SID identifier of the Factor to which the Challenge is related
    - pageSize: Number of Challenges to be returned by the service
    - status: Status to filter the Challenges, if nothing is sent, Challenges of all status will be
              returned
    - pageToken: Token used to retrieve the next page in the pagination arrangement
  */
  public init(factorSid: String, pageSize: Int, status: ChallengeStatus? = nil, pageToken: String? = nil) {
    self.factorSid = factorSid
    self.pageSize = pageSize
    self.status = status
    self.pageToken = pageToken
  }
}
