//
//  NetworkAdapterTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

// swiftlint:disable force_cast
class NetworkAdapterTests: XCTestCase {
  
  func testRequest_withSuccessResponseCode_shouldReturnExpectedResponse() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedHeaders = ["key1": "value1", "key2": "value2"]
    let expectedDataResponse = "response".data(using: .utf8)!
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: expectedHeaders)
    let session = URLSessionMock(data: expectedDataResponse, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: session)
    let urlRequest = URLRequest(url: URL(string: Constants.url)!)
    
    networkProvider.execute(urlRequest, success: { response in
      XCTAssertEqual(response.data, expectedDataResponse, "Response data should be \(expectedDataResponse) but was \(response.data)")
      expectedHeaders.forEach {
        XCTAssertEqual($0.value, response.headers[$0.key] as! String,
                       "Header should be \($0.value) but was \(response.headers[$0.key] as! String)")
      }
      successExpectation.fulfill()
    }) { _ in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
  }
  
  func testRequest_withFailureResponseCode_shouldReturnInvalidResponseError() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedDataResponse = "response".data(using: .utf8)!
    let statusCode = 400
    let headersFields = ["key": "value"]
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: statusCode, httpVersion: "", headerFields: headersFields)
    let session = URLSessionMock(data: expectedDataResponse, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: session)
    let urlRequest = URLRequest(url: URL(string: Constants.url)!)
    var error: Error!
    networkProvider.execute(urlRequest, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { failure in
      error = failure
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    let failureResponse = (error as! NetworkError).failureResponse!
    let expectedError = NetworkError.failureStatusCode(
      failureResponse: FailureResponse(
        responseCode: statusCode,
        errorData: expectedDataResponse,
        headers: headersFields))
    XCTAssertEqual((error as! NetworkError).errorDescription, expectedError.errorDescription)
    XCTAssertEqual(failureResponse.responseCode, statusCode)
    XCTAssertEqual(failureResponse.errorData, expectedDataResponse)
    XCTAssertEqual(failureResponse.headers as! [String: String], headersFields)
  }
  
  func testRequest_withNoData_shouldReturnInvalidDataError() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 400, httpVersion: "", headerFields: nil)
    let session = URLSessionMock(data: nil, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: session)
    let urlRequest = URLRequest(url: URL(string: Constants.url)!)
    
    networkProvider.execute(urlRequest, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual((error as! NetworkError).errorDescription, NetworkError.invalidData.errorDescription)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testRequest_withErrorResponse_shouldReturnError() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedDataResponse = "failure".data(using: .utf8)!
    let expectedError = NetworkError.invalidResponse(errorResponse: expectedDataResponse)
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let session = URLSessionMock(data: nil, httpURLResponse: urlResponse, error: expectedError)
    let networkProvider = NetworkAdapter(withSession: session)
    let urlRequest = URLRequest(url: URL(string: Constants.url)!)
    
    networkProvider.execute(urlRequest, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual((error as! NetworkError).errorDescription, NetworkError.invalidResponse(errorResponse: expectedDataResponse).errorDescription)
      XCTAssertEqual((error as! NetworkError).errorResponse, expectedDataResponse)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
}

private extension NetworkAdapterTests {
  struct Constants {
    static let url = "https://twilio.com"
  }
}
