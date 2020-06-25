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
  var error: TwilioVerifyError?
  var challenge: Challenge!
}

extension ChallengeProviderMock: ChallengeProvider {
  func get(forSid sid: String, withFactor factor: Factor, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(challenge)
  }
}
