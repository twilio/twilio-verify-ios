//
//  NetworkProviderMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/5/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class NetworkProviderMock: NetworkProvider {
  var response: Response?
  var error: Error?
  var urlRequest: URLRequest?
  
  func execute(_ urlRequest: URLRequest, success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
    self.urlRequest = urlRequest
    if let response = response {
      success(response)
    }
    if let error = error {
      failure(error)
    }
  }
}
