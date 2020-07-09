//
//  FactorFacadeMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/23/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
