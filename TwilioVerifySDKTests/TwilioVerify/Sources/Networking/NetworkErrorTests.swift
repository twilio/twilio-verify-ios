//
//  NetworkAdapterTests.swift
//  NetworkErrorTests
//
//  Copyright © 2022 Twilio.
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

import XCTest
@testable import TwilioVerifySDK

class NetworkErrorTests: XCTestCase {
  func testDataConversion_toServerError_shouldSucceeded() {
    let testObject = [
      "code": 1234,
      "message": "hello!",
      "more_info": "https://google.com"
    ] as [String: Any]
    
    do {
      let data = try JSONSerialization.data(
        withJSONObject: testObject,
        options: []
      )
      
      let serverError = NetworkError.tryConvertDataToAPIError(data)
      
      XCTAssertNotNil(serverError)
      XCTAssertEqual(serverError?.code, testObject["code"] as? Int)
      XCTAssertEqual(serverError?.message, testObject["message"] as? String)
      XCTAssertEqual(serverError?.moreInfo, testObject["more_info"] as? String)
    } catch {
      XCTFail("Unable to convert test JSON to data, check syntax")
    }
  }
  
  func testDataConversion_toServerErrorWithInvalidData_shouldFail() {
    let testObject = [
      "message": "hello!"
    ] as [String: Any]
    
    do {
      try JSONSerialization.data(
        withJSONObject: testObject,
        options: []
      )
      XCTAssertNil(NetworkError.tryConvertDataToAPIError(data))
    } catch {
      XCTFail("Unable to convert test JSON to data, check syntax")
    }
  }
}
