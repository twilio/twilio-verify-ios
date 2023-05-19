//
//  ChallengeAPIClientMock.swift
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
@testable import TwilioVerifySDK

class ChallengeAPIClientMock {
  var challengeData: Data!
  var headers: [String: String]!
  var expectedChallengeSid: String!
  var expectedFactor: Factor!
  var expectedPayload: String!
  var expectedChallenge: Challenge!
  var error: Error?
}

extension ChallengeAPIClientMock: ChallengeAPIClientProtocol {
  
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    if sid == expectedChallengeSid, factor.sid == expectedFactor.sid {
      success(NetworkResponse(data: challengeData, headers: headers))
      return
    }
    fatalError("Expected params not set")
  }
  
  func update(_ challenge: FactorChallenge, withAuthPayload authPayload: String, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    if challenge.sid == expectedChallenge.sid, authPayload == expectedPayload {
      success(NetworkResponse(data: challengeData, headers: headers))
      return
    }
    fatalError("Expected params not set")
  }
  
  func getAll(forFactor factor: Factor, status: String?, pageSize: Int, order: ChallengeListOrder, pageToken: String?, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    
  }
}
