//
//  ChallengeProviderMock.swift
//  TwilioVerifyTests
//
//  Created by Yeimi Moreno on 6/24/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class ChallengeProviderMock {
  var error: Error?
  var challenge: Challenge!
  var updatedChallenge: Challenge!
  var errorUpdating: Error?
  var challengeList: ChallengeList!
}

extension ChallengeProviderMock: ChallengeProvider {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(challenge)
  }
  
  func update(_ challenge: Challenge, payload: String, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock) {
    if let error = errorUpdating {
      failure(error)
      return
    }
    if let updatedChallenge = updatedChallenge {
      success(updatedChallenge)
    }
  }
  
  func getAll(for factor: Factor, status: ChallengeStatus?, pageSize: Int, pageToken: String?, success: @escaping (ChallengeList) -> (), failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(challengeList)
  }
}
