//
//  FactorAPIClientMock.swift
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
@testable import TwilioVerifySDK

class FactorAPIClientMock {
  var factorData: Data!
  var statusData: Data!
  var expectedFactorSid: String!
  var error: Error?
}

extension FactorAPIClientMock: FactorAPIClientProtocol {
  func create(withPayload payload: CreateFactorPayload, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(NetworkResponse(data: factorData, headers: [:]))
  }
  
  func verify(_ factor: Factor, authPayload: String, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    if factor.sid == expectedFactorSid {
      success(NetworkResponse(data: statusData, headers: [:]))
      return
    }
    fatalError("Expected params not set")
  }
  
  func delete(_ factor: Factor, success: @escaping EmptySuccessBlock, failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    success()
  }
  
  func update(_ factor: Factor, updateFactorDataPayload: UpdateFactorDataPayload, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    if factor.sid == expectedFactorSid {
      success(NetworkResponse(data: statusData, headers: [:]))
      return
    }
    fatalError("Expected params not set")
  }
}
