//
//  HTTPHeadersTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/1/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class HTTPHeadersTests: XCTestCase {
  
  typealias HeaderConstants = HTTPHeader.Constant
  
  func testGetDictionary_shouldContaintExpectedHeaders() {
    let expectedHeaders = [HTTPHeader.accept("accept"), HTTPHeader.contentType("content")]
    var httpHeaders = HTTPHeaders()
    httpHeaders.addAll(expectedHeaders)
    let headersDict = httpHeaders.dictionary
    XCTAssertEqual(headersDict?.count, expectedHeaders.count,
                   "Headers size should be \(expectedHeaders.count) but were \(String(describing: headersDict?.count))")
    XCTAssertEqual(headersDict?[HeaderConstants.acceptType], expectedHeaders.first { $0.key == HeaderConstants.acceptType }?.value,
                   "Header should be \(expectedHeaders.first { $0.key == HeaderConstants.acceptType }!.value) but was \(headersDict![HeaderConstants.acceptType]!)")
    XCTAssertEqual(headersDict?[HeaderConstants.contentType], expectedHeaders.first { $0.key == HeaderConstants.contentType }?.value,
                   "Header should be \(expectedHeaders.first { $0.key == HeaderConstants.contentType }!.value) but was \(headersDict![HTTPHeader.Constant.contentType]!)")
  }
}
