//
//  FactorMapperMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/10/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class FactorMapperMock {
  var expectedFactor: Factor?
  var expectedData: Data?
  var expectedFactorPayload: FactorPayload?
  var error: Error?
}

extension FactorMapperMock: FactorMapperProtocol {
  func fromAPI(withData data: Data, factorPayload: FactorPayload) throws -> Factor {
    if let error = error {
      throw error
    }
    if let expectedData = expectedData, let expectedFactorPayload = expectedFactorPayload, expectedData == data, expectedFactorPayload.entity == factorPayload.entity
    {
      return try JSONDecoder().decode(PushFactor.self, from: expectedData)
    }
    fatalError("Expected params not set")
  }
  
  func toData(_ factor: Factor) throws -> Data {
    if let error = error {
      throw error
    }
    if let expectedFactor = expectedFactor, expectedFactor.sid == factor.sid {
      return try JSONEncoder().encode(factor as? PushFactor)
    }
    fatalError("Expected params not set")
  }
  
  func fromStorage(withData data: Data) throws -> Factor {
    if let error = error {
      throw error
    }
    if let expectedData = expectedData, expectedData == data {
      return try JSONDecoder().decode(PushFactor.self, from: expectedData)
    }
    fatalError("Expected params not set")
  }
  
  func status(fromData data: Data) throws -> FactorStatus {
    if let error = error {
      throw error
    }
    if let expectedData = expectedData, expectedData == data {
      return try JSONDecoder().decode(FactorStatus.self, from: data)
    }
    fatalError("Expected params not set")
  }
}
