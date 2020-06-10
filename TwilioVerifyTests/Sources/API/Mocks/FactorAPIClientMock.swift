//
//  FactorAPIClientMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/10/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class FactorAPIClientMock {
  var factor: Data!
  var error: Error?
}

extension FactorAPIClientMock: FactorAPIClientProtocol {
  func create(createFactorPayload: CreateFactorPayload, success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
    if let error = error {
      failure(error)
      return
    }
    success(Response(data: factor, headers: [:]))
  }
}
