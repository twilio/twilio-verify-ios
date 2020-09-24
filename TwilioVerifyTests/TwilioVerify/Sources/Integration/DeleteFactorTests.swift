//
//  DeleteFactorTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 7/16/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

// swiftlint:disable force_try
class DeleteFactorTests: BaseFactorTests {
  
  func testDeleteFactor_withFactorStored_shouldSucceed() {
    let expectation = self.expectation(description: "testDeleteFactor_withValidFactor_shouldSucceed")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: "".data(using: .utf8), httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
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
    let twilioVerify = try! TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
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
    let twilioVerify = try! TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    let expectedError = TwilioVerifyError.storageError(error: TestError.operationFailed as NSError)
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
    let twilioVerify = try! TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
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
