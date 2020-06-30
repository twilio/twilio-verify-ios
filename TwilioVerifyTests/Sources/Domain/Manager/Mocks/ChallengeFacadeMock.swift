//
//  ChallengeFacadeMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/30/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class ChallengeFacadeMock: ChallengeFacadeProtocol {
  func get(withSid sid: String, withFactorSid factorSid: String, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  func update(withPayload updateChallengePayload: UpdateChallengePayload, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
  
  }
  
  func getAll(withPayload challengeListPayload: ChallengeListPayload, success: @escaping (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
}
