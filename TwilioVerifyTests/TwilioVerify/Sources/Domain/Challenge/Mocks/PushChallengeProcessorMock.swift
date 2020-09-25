//
//  PushChallengeProcessorMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
