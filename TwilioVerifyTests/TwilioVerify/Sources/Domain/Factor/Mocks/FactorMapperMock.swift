//
//  FactorMapperMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
@testable import TwilioVerify

class FactorMapperMock {
  var expectedFactor: Factor?
  var expectedData: Data?
  var expectedDataList: [Data]?
  var expectedStatusData: Data?
  var expectedFactorPayload: FactorDataPayload?
  var error: Error?
  var fromAPIError: Error?
  private(set) var callToFromStorage = 0
}

extension FactorMapperMock: FactorMapperProtocol {
  func fromAPI(withData data: Data, factorPayload: FactorDataPayload) throws -> Factor {
    if let error = fromAPIError {
      throw error
    }
    if let expectedData = expectedData, let expectedFactorPayload = expectedFactorPayload, expectedData == data, expectedFactorPayload.identity == factorPayload.identity {
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
      return try JSONDecoder().decode(PushFactor.self, from: data)
    }
    if let expectedData = expectedData {
      return try JSONDecoder().decode(PushFactor.self, from: expectedData)
    }
    if let expectedData = expectedDataList?[callToFromStorage] {
      callToFromStorage += 1
      return try JSONDecoder().decode(PushFactor.self, from: expectedData)
    }
    fatalError("Expected params not set")
  }
  
  func status(fromData data: Data) throws -> FactorStatus {
    if let error = error {
      throw error
    }
    if let expectedData = expectedStatusData, expectedData == data {
      guard let jsonFactor = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
        let status = jsonFactor[(\Factor.status).toString] as? String,
        let factorStatus = FactorStatus(rawValue: status) else {
          throw MapperError.invalidArgument
      }
      return factorStatus
    }
    fatalError("Expected params not set")
  }
}
