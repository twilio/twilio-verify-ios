//
//  ChallengeMapperMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

class ChallengeMapperMock {
  var expectedData: Data?
  var expectedSignatureFieldsHeader: String?
  var factorChallenge: FactorChallenge?
  var error: Error?
  private(set) var callsToMap = 0
}

extension ChallengeMapperMock: ChallengeMapperProtocol {
  func fromAPI(withData data: Data, signatureFieldsHeader: String?) throws -> FactorChallenge {
    if let error = error {
      throw error
    }
    callsToMap += 1
    if let expectedData = expectedData, expectedData == data,
       let factorChallenge = factorChallenge, expectedSignatureFieldsHeader == signatureFieldsHeader {
      return factorChallenge
    }
    fatalError("Expected params not set")
  }
  
  func fromAPI(withChallengeDTO challengeDTO: ChallengeDTO) throws -> FactorChallenge {
    if let error = error {
      throw error
    }
    callsToMap += 1
    if let factorChallenge = factorChallenge {
      return factorChallenge
    }
    fatalError("Expected params not set")
  }
}
