//
//  ChallengeFacadeMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

class ChallengeFacadeMock {
  var challenge: Challenge!
  var challengeList: ChallengeList!
  var error: TwilioVerifyError?
}

extension ChallengeFacadeMock: ChallengeFacadeProtocol {
  func get(withSid sid: String, withFactorSid factorSid: String, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(challenge)
  }
  
  func update(withPayload updateChallengePayload: UpdateChallengePayload, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success()
  }
  
  func getAll(withPayload challengeListPayload: ChallengeListPayload, success: @escaping (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(challengeList)
  }
}
