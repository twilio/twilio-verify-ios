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
  func createFactor(withInput input: FactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factor)
  }
  
  func verifyFactor(withInput input: VerifyFactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(factor)
  }
}
