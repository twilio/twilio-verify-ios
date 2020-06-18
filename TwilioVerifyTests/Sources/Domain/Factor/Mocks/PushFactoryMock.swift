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
}

extension PushFactoryMock: PushFactoryProtocol {
  func createFactor(withJwe jwe: String, friendlyName: String, pushToken: String, serviceSid: String, identity: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
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
}
