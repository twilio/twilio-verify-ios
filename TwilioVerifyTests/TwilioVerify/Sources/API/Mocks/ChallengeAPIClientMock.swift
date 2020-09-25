//
//  ChallengeAPIClientMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

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
      success(Response(data: challengeData, headers: headers))
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
      success(Response(data: challengeData, headers: headers))
      return
    }
    fatalError("Expected params not set")
  }
  
  func getAll(forFactor factor: Factor, status: String?, pageSize: Int, pageToken: String?, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    
  }
}
