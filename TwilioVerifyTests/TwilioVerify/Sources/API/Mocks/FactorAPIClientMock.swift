//
//  FactorAPIClientMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

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
    success(Response(data: factorData, headers: [:]))
  }
  
  func verify(_ factor: Factor, authPayload: String, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    if factor.sid == expectedFactorSid {
      success(Response(data: statusData, headers: [:]))
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
      success(Response(data: statusData, headers: [:]))
      return
    }
    fatalError("Expected params not set")
  }
}
