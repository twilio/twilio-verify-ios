//
//  ChallengeAPIClientMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
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
  
  func update(_ challenge: FactorChallenge, withAuthPayload authPayload: String, success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
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
}
