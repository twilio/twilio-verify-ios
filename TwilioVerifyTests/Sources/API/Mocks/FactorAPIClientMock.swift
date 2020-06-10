//
//  FactorAPIClientMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/10/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class FactorAPIClientMock: FactorAPIClient {
  var factor: Data?
  var error: Error?
  
  override func create(createFactorPayload: CreateFactorPayload, success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
    if let factor = factor {
      success(Response(data: factor, headers: [:]))
    }
    if let error = error {
      failure(error)
    }
  }
}
