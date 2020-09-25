//
//  HTTPHeadersTests.swift
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
