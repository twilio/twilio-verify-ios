//
//  ChallengeMapperMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
