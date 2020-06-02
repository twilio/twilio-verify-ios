//
//  URLSessionMockConfiguration.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest

struct URLSessionMockConfiguration {
  var data: Data?
  var httpURLResponse: HTTPURLResponse?
  var expectation: XCTestExpectation?
  var url: URL?
  var error: Error?
  
  init(expectation: XCTestExpectation, url: URL? = nil, error: Error? = nil, data: Data? = nil, httpURLResponse: HTTPURLResponse? = nil) {
    self.expectation = expectation
    self.url = url
    self.error = error
    self.httpURLResponse = httpURLResponse
    self.data = data
  }
}
