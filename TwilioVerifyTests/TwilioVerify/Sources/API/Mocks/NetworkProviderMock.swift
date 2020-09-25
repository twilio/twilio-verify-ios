//
//  NetworkProviderMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import XCTest
@testable import TwilioVerify

// swiftlint:disable force_cast
class NetworkProviderMock: NetworkProvider {
  var response: Response?
  var responses: [Any]?
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
      switch response {
        case is Response:
          success(response as! Response)
        case is Error:
          failure(response as! Error)
        default:
          fatalError("Expected params not set")
      }
      return
    }
    if let error = error {
      callsToExecute += 1
      failure(error)
    }
  }
}
