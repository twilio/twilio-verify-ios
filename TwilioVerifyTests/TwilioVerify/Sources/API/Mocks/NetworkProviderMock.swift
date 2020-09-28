//
//  NetworkProviderMock.swift
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
