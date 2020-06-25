//
//  ChallengeListMapperMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

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
