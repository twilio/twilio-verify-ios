//
//  PushFactoryMock.swift
//  TwilioVerifyTests
//
//  Created by Santiago Avila on 6/12/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
