//
//  ChallengeListPayload.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

///Describes the information required to fetch a **ChallengeList**
public struct ChallengeListPayload {
  ///The unique SID identifier of the Factor to which the **ChallengeList** is related
  public let factorSid: String
  ///Number of Challenges to be returned by the service
  public let pageSize: Int
  ///Sort challenges in order by creation date of the challenge
  public let order: ChallengeListOrder
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
    - order: Sort challenges in order by creation date of the challenge
    - pageToken: Token used to retrieve the next page in the pagination arrangement
  */
  public init(factorSid: String, pageSize: Int, status: ChallengeStatus? = nil, order: ChallengeListOrder = .asc, pageToken: String? = nil) {
    self.factorSid = factorSid
    self.pageSize = pageSize
    self.order = order
    self.status = status
    self.pageToken = pageToken
  }
}

///Describes the order to fetch a **ChallengeList**
public enum ChallengeListOrder: String, Codable {
  case asc
  case desc
}
