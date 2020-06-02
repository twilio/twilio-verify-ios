//
//  FactorChallengeList.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct FactorChallengeList: ChallengeList {
  let challenges: [Challenge]
  let metadata: Metadata
  
  init(challenges: [Challenge], metadata: Metadata) {
    self.challenges = challenges
    self.metadata = metadata
  }
}
