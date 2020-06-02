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
  
  func testGetDictionary_shouldContaintExpectedHeaders() {
    let expectedHeaders = [HTTPHeader.accept("accept"), HTTPHeader.contentType("content")]
    var httpHeaders = HTTPHeaders()
    httpHeaders.addAll(expectedHeaders)
    let headersDict = httpHeaders.dictionary
    XCTAssertEqual(headersDict?.count, expectedHeaders.count,
                   "Headers size should be \(expectedHeaders.count) but were \(String(describing: headersDict?.count))")
    XCTAssertEqual(headersDict?[HTTPHeader.Constant.acceptType], expectedHeaders.first { $0.key == HTTPHeader.Constant.acceptType }?.value,
                   "Header should be \(String(describing: expectedHeaders.first { $0.key == HTTPHeader.Constant.acceptType }?.value)) but was \(String(describing: headersDict?[HTTPHeader.Constant.acceptType]))")
    XCTAssertEqual(headersDict?[HTTPHeader.Constant.contentType], expectedHeaders.first { $0.key == HTTPHeader.Constant.contentType }?.value,
                   "Header should be \(String(describing: expectedHeaders.first { $0.key == HTTPHeader.Constant.contentType }?.value)) but was \(String(describing: headersDict?[HTTPHeader.Constant.contentType]))")
  }
}
