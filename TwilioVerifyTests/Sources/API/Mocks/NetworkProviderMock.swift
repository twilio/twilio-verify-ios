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
  var responses: [Response]?
  var error: Error?
  private(set) var callsToExecute = 0
  private(set) var urlRequest: URLRequest?
  
  func execute(_ urlRequest: URLRequest, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    self.urlRequest = urlRequest
    if let response = response {
      success(response)
      return
    }
    if let response = responses?[callsToExecute] {
      callsToExecute += 1
      success(response)
      return
    }
    if let error = error {
      failure(error)
    }
  }
}
