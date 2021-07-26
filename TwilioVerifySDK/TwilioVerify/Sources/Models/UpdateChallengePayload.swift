//
//  UpdateChallengePayload.swift
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

///Describes the information required to update a **Challenge**
public protocol UpdateChallengePayload {
  ///Sid of the Factor to which the Challenge is related
  var factorSid: String { get }
  ///Sid of the Challenge to be updated
  var challengeSid: String { get }
}

///Describes the information required to update a **Push Challenge**
public struct UpdatePushChallengePayload: UpdateChallengePayload {
  ///Sid of the Factor to which the Challenge is related
  public let factorSid: String
  ///Sid of the Challenge to be updated
  public let challengeSid: String
  //New status of the Challenge
  public let status: ChallengeStatus
  
  /**
  Creates an **UpdatePushChallengePayload** with the given parameters
  - Parameters:
    - factorSid: Sid of the Factor to which the Challenge is related
    - challengeSid: Sid of the Challenge to be updated
    - status: New status of the Challenge
  */
  public init(factorSid: String, challengeSid: String, status: ChallengeStatus) {
    self.factorSid = factorSid
    self.challengeSid = challengeSid
    self.status = status
  }
}
