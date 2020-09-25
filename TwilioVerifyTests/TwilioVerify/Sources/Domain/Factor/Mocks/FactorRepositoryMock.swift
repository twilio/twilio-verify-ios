//
//  FactorRepositoryMock.swift
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

class FactorRepositoryMock {
  var error: Error?
  var saveError: Error?
  var verifyError: Error?
  var updateError: Error?
  var deleteError: Error?
  var factor: Factor!
  var factors: [Factor]!
}

extension FactorRepositoryMock: FactorProvider {
  func create(withPayload payload: CreateFactorPayload, success: @escaping (Factor) -> (), failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factor)
  }
  
  func verify(_ factor: Factor, payload: String, success: @escaping FactorSuccessBlock, failure: @escaping FailureBlock) {
    if let error = verifyError {
      failure(error)
      return
    }
    self.factor.status = FactorStatus.verified
    success(self.factor)
  }
  
  func delete(_ factor: Factor, success: @escaping EmptySuccessBlock, failure: @escaping FailureBlock) {
    if let error = deleteError {
      failure(error)
      return
    }
    success()
  }
  
  func update(withPayload payload: UpdateFactorDataPayload, success: @escaping FactorSuccessBlock, failure: @escaping FailureBlock) {
    if let error = updateError {
      failure(error)
      return
    }
    success(factor)
  }
  
  func getAll(success: @escaping FactorListSuccessBlock, failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factors)
  }
  
  func get(withSid sid: String) throws -> Factor {
    if let error = error {
      throw error
    }
    return factor
  }
  
  func save(_ factor: Factor) throws -> Factor {
    if let error = saveError {
      throw error
    }
    return factor
  }
}
