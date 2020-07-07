//
//  FactorRepositoryMock.swift
//  TwilioVerifyTests
//
//  Created by Santiago Avila on 6/11/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class FactorRepositoryMock {
  var error: Error?
  var saveError: Error?
  var verifyError: Error?
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
  
  func getAll(success: @escaping ([Factor]) -> (), failure: @escaping FailureBlock) {
    if let error = deleteError {
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
