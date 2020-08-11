//
//  ChallengeList.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
