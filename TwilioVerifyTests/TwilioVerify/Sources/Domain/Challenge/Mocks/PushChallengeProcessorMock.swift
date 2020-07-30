//
//  PushChallengeProcessorMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/30/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
