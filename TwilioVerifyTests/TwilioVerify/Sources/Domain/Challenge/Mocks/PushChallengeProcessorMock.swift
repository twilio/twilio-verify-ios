//
//  PushChallengeProcessorMock.swift
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

class PushChallengeProcessorMock {
  var challenge: Challenge!
  var error: TwilioVerifyError?
  var expectedSid: String!
  var expectedFactor: Factor!
}

extension PushChallengeProcessorMock: PushChallengeProcessorProtocol {
  func getChallenge(withSid sid: String, withFactor factor: PushFactor, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    if sid == expectedSid, factor.sid == expectedFactor.sid {
      success(challenge)
      return
    }
    fatalError("Expected params not set")
  }
  
  func updateChallenge(withSid sid: String, withFactor factor: PushFactor, status: ChallengeStatus, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    if sid == expectedSid, factor.sid == expectedFactor.sid {
      success()
      return
    }
    fatalError("Expected params not set")
  }
}
