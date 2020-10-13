//
//  ChallengeProviderMock.swift
//  TwilioVerifyTests
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
