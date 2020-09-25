//
//  ChallengeListMapperMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

class ChallengeListMapperMock {
  var error: Error?
}

extension ChallengeListMapperMock: ChallengeListMapperProtocol {
  func fromAPI(withData data: Data) throws -> ChallengeList {
    if let error = error {
      throw error
    }
    fatalError("Expected params not set")
  }
}
