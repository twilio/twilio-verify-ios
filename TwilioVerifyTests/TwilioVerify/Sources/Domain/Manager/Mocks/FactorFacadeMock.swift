//
//  FactorFacadeMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

class FactorFacadeMock {
  var factor: Factor!
  var error: TwilioVerifyError?
}

extension FactorFacadeMock: FactorFacadeProtocol {
  func createFactor(withPayload payload: FactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factor)
  }
  
  func verifyFactor(withPayload payload: VerifyFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factor)
  }
  
  func updateFactor(withPayload payload: UpdateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factor)
  }
  
  func get(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factor)
  }
  
  func getAll(success: @escaping FactorListSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success([factor])
  }
  
  func delete(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success()
  }
}
