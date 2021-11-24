//
//  PushFactoryMock.swift
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

class PushFactoryMock {
  var error: TwilioVerifyError?
  var factor: Factor!
  var deleteFactorCalled = false
}

extension PushFactoryMock: PushFactoryProtocol {
  func createFactor(withAccessToken accessToken: String, friendlyName: String, serviceSid: String, identity: String,
                    pushToken: String?, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
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
  
  func updateFactor(withSid sid: String, withPushToken pushToken: String?, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
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
  
  func deleteAllFactors() throws {
    if let error = error {
      throw error
    }
  }
}
