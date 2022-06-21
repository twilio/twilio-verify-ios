//
//  DeleteFactorTests.swift
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
@testable import TwilioVerifySDK

// swiftlint:disable force_try
class DeleteFactorTests: BaseFactorTests {
  
  func testDeleteFactor_withFactorStored_shouldSucceed() {
    let expectation = self.expectation(description: "testDeleteFactor_withValidFactor_shouldSucceed")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: "".data(using: .utf8), httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder()
                            .setNetworkProvider(networkProvider)
                            .setClearStorageOnReinstall(true)
                            .enableDefaultLoggingService(withLevel: .all)
                            .build()
    twilioVerify.deleteFactor(withSid: factor!.sid, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testDeleteFactor_withNoExistingFactor_shouldSucceed() {
    let expectation = self.expectation(description: "testDeleteFactor_withNoExistingFactor_shouldSucceed")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 401, httpVersion: "", headerFields: [BaseAPIClient.Constants.dateHeaderKey: "Tue, 21 Jul 2020 17:07:32 GMT"])
    let urlSession = URLSessionMock(data: "".data(using: .utf8), httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder()
                            .setNetworkProvider(networkProvider)
                            .setClearStorageOnReinstall(true)
                            .enableDefaultLoggingService(withLevel: .all)
                            .build()
    twilioVerify.deleteFactor(withSid: factor!.sid, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testDeleteFactor_withFactorNotStored_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withFactorNotStored_shouldFail")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: "".data(using: .utf8), httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder()
                            .setNetworkProvider(networkProvider)
                            .setClearStorageOnReinstall(true)
                            .enableDefaultLoggingService(withLevel: .all)
                            .build()
    let expectedError = TwilioVerifyError.storageError(error: TestError.operationFailed)
    var error: TwilioVerifyError!
    twilioVerify.deleteFactor(withSid: "anotherSid", success: {
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
  
  func testDeleteFactor_withInvalidApiResponse_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withInvalidApiResponse_shouldFail")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 400, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: "".data(using: .utf8), httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder()
                            .setNetworkProvider(networkProvider)
                            .setClearStorageOnReinstall(true)
                            .enableDefaultLoggingService(withLevel: .all)
                            .build()
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed)
    var error: TwilioVerifyError!
    twilioVerify.deleteFactor(withSid: factor!.sid, success: {
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
}

private extension DeleteFactorTests {
  struct Constants {
    static let url = "https://twilio.com"
  }
}
