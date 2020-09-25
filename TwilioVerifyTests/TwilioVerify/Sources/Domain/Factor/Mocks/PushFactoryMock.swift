//
//  PushFactoryMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

class PushFactoryMock {
  var error: TwilioVerifyError?
  var factor: Factor!
  var deleteFactorCalled = false
}

extension PushFactoryMock: PushFactoryProtocol {
  func createFactor(withAccessToken accessToken: String, friendlyName: String, pushToken: String,
                    serviceSid: String, identity: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factor)
  }
  
  func verifyFactor(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factor)
  }
  
  func updateFactor(withSid sid: String, withPushToken pushToken: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factor)
  }
  
  func deleteFactor(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    deleteFactorCalled = true
    if let error = error {
      failure(error)
      return
    }
    success()
  }
}
