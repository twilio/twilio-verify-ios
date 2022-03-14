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
  func testAPIError_fromLocalError_shouldSerializeToServerError() {
    let expectedCode = 500
    let expectedMessage = "error"
    let expectedInfo = "web error"
    
    let error = APIError(
      code: expectedCode,
      message: expectedMessage,
      moreInfo: expectedInfo
    )

    do {
      let data = try JSONEncoder().encode(error)
      let jsonData = (try JSONSerialization.jsonObject(
        with: data,
        options: []
      ) as? [String: Any]) ?? [:]
      
      XCTAssertEqual(jsonData["code"] as? Int, expectedCode)
      XCTAssertEqual(jsonData["message"] as? String, expectedMessage)
      XCTAssertEqual(jsonData["more_info"] as? String, expectedInfo)
    } catch {
      XCTFail("Unable to convert test data, check syntax")
    }
  }
  
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
      let data = try JSONSerialization.data(
        withJSONObject: testObject,
        options: []
      )
      XCTAssertNil(NetworkError.tryConvertDataToAPIError(data))
    } catch {
      XCTFail("Unable to convert test JSON to data, check syntax")
    }
  }
}
