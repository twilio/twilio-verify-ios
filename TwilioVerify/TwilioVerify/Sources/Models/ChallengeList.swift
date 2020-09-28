//
//  ChallengeList.swift
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

///Describes the information of a **ChallengeList**
public protocol ChallengeList {
  ///Array of Challenges that matches the parameters of the **ChallengeListPayload** used
  var challenges: [Challenge] { get }
  ///Metadata returned by the /Challenges endpoint, used to fetch subsequent pages of Challenges
  var metadata: Metadata { get }
}

///Describes the information of a **ChallengeList**
struct FactorChallengeList: ChallengeList {
  ///Array of Challenges that matches the parameters of the **ChallengeListPayload** used
  let challenges: [Challenge]
  ///Metadata returned by the /Challenges endpoint, used to fetch subsequent pages of Challenges
  let metadata: Metadata
}
