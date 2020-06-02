//
//  NetworkAdapterTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class NetworkAdapterTests: XCTestCase {
  
  private var networkProvider: NetworkAdapter!
  private var session: URLSessionMock!
  
  override func setUpWithError() throws {
    session = URLSessionMock()
    networkProvider = NetworkAdapter(withSession: session)
  }
  
  func testRequest_withSuccessResponseCode_shouldReturnExpectedResponse() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedHeaders = ["key1": "value1", "key2": "value2"]
    guard let expectedDataResponse = "response".data(using: .utf8) else {
      XCTFail("Data is nil")
      return
    }
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: expectedHeaders)
    session.sessionConfiguration = URLSessionMockConfiguration(expectation: successExpectation,
                                                               data: expectedDataResponse,
                                                               httpURLResponse: urlResponse)
    
    let urlRequest = URLRequest(url: URL(string: Constants.url)!)
    networkProvider.execute(urlRequest, success: { response in
      XCTAssertEqual(response.data, expectedDataResponse, "Response data should be \(expectedDataResponse) but was \(response.data)")
      expectedHeaders.forEach {
        XCTAssertEqual($0.value, response.headers[$0.key] as! String,
                       "Header should be \($0.value) but was \(response.headers[$0.key] as! String)")
      }
    }) { error in
      XCTFail("Should not be called")
    }
    wait(for: [successExpectation], timeout: 5)
  }
  
  func testRequest_withFailureResponseCode_shouldReturnInvalidResponseError() {
    let failureExpectation = expectation(description: "Wait for failure response")
    guard let expectedDataResponse = "response".data(using: .utf8) else {
      XCTFail("Data is nil")
      return
    }
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 400, httpVersion: "", headerFields: nil)
    session.sessionConfiguration = URLSessionMockConfiguration(expectation: failureExpectation,
                                                               data: expectedDataResponse,
                                                               httpURLResponse: urlResponse)
    
    let urlRequest = URLRequest(url: URL(string: Constants.url)!)
    networkProvider.execute(urlRequest, success: { response in
      XCTFail("Should not be called")
    }) { error in
      XCTAssertEqual(error as! NetworkError, NetworkError.invalidResponse(errorResponse: expectedDataResponse))
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testRequest_withNoDate_shouldReturnInvalidDataError() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 400, httpVersion: "", headerFields: nil)
    session.sessionConfiguration = URLSessionMockConfiguration(expectation: failureExpectation,
                                                               httpURLResponse: urlResponse)
    
    let urlRequest = URLRequest(url: URL(string: Constants.url)!)
    networkProvider.execute(urlRequest, success: { response in
      XCTFail("Should not be called")
    }) { error in
      XCTAssertEqual(error as! NetworkError, NetworkError.invalidData)
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  
  func testRequest_withErrorResponse_shouldReturnError() {
    let failureExpectation = expectation(description: "Wait for failure response")
    guard let expectedDataResponse = "failure".data(using: .utf8) else {
      XCTFail("Data is nil")
      return
    }
    let expectedError = NetworkError.invalidResponse(errorResponse: expectedDataResponse)
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    session.sessionConfiguration = URLSessionMockConfiguration(expectation: failureExpectation,
                                                               error: expectedError,
                                                               httpURLResponse: urlResponse)
    
    let urlRequest = URLRequest(url: URL(string: Constants.url)!)
    networkProvider.execute(urlRequest, success: { response in
      XCTFail("Should not be called")
    }) { error in
      XCTAssertEqual(error as! NetworkError, expectedError)
    }
    wait(for: [failureExpectation], timeout: 5)
  }
}

private extension NetworkAdapterTests {
  struct Constants {
    static let url = "https://twilio.com"
  }
}
