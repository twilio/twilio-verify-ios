//
//  URLSessionMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest

class URLSessionMock: URLSession {
  
  var sessionConfiguration: URLSessionMockConfiguration?
  
  override func dataTask(with request: URLRequest) -> URLSessionDataTask {
    return URLSessionDataTaskMock(expectation: sessionConfiguration!.expectation!)
  }
  
  override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    completionHandler(sessionConfiguration?.data, sessionConfiguration?.httpURLResponse, sessionConfiguration?.error)
    return URLSessionDataTaskMock(expectation: sessionConfiguration!.expectation!)
  }
}

class URLSessionDataTaskMock: URLSessionDataTask {
  
  let expectation: XCTestExpectation
  
  init(expectation: XCTestExpectation) {
    self.expectation = expectation
  }
  
  override func resume() {
    expectation.fulfill()
  }
}
