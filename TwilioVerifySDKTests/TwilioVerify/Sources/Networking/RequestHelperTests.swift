//
//  RequestHelperTests.swift
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

class RequestHelperTests: XCTestCase {
  
  private var appInfo: [String: Any]!
  private var frameworkInfo: [String: Any]!
  private let authorization = BasicAuthorization(username: "username", password: "password")
  private var requestHelper: RequestHelper!
  private let paramsCount = 4
  
  override func setUpWithError() throws {
    appInfo = Bundle.main.infoDictionary
    frameworkInfo = Bundle(for: type(of: self)).infoDictionary
    requestHelper = RequestHelper(authorization: authorization)
  }
  
  func testCommonHeaders_withPostHTTPMethod_shouldContainExpectedParams() {
    let commonHeaders = requestHelper.commonHeaders(httpMethod: .post)

    let userAgent = commonHeaders.first { $0.key == HTTPHeader.Constant.userAgent }
    let authorization = commonHeaders.first { $0.key == HTTPHeader.Constant.authorization }
    let acceptType = commonHeaders.first { $0.key == HTTPHeader.Constant.acceptType }
    let contentType = commonHeaders.first { $0.key == HTTPHeader.Constant.contentType }
    XCTAssertEqual(commonHeaders.count, paramsCount,
                   "Headers size should be \(paramsCount) but were \(commonHeaders.count)")
    XCTAssertEqual(acceptType?.value, MediaType.json.value,
                   "Accept header should be \(MediaType.json.value) but was \(acceptType!.value)")
    XCTAssertEqual(contentType?.value, MediaType.urlEncoded.value,
                   "Content-type header should be \(MediaType.urlEncoded.value) but was \(contentType!.value)")
    XCTAssertEqual(authorization?.value, self.authorization.header().value,
                   "Authorization header should be \(self.authorization.header().value) but was \(String(describing: authorization?.value))")
    XCTAssertNotNil(userAgent, "User-agent header should not be nil")
  }
  
  func testCommonHeaders_withGetHTTPMethod_shouldContainExpectedParams() {
    let commonHeaders = requestHelper.commonHeaders(httpMethod: .get)
    
    let userAgent = commonHeaders.first { $0.key == HTTPHeader.Constant.userAgent }
    let authorization = commonHeaders.first { $0.key == HTTPHeader.Constant.authorization }
    let acceptType = commonHeaders.first { $0.key == HTTPHeader.Constant.acceptType }
    let contentType = commonHeaders.first { $0.key == HTTPHeader.Constant.contentType }
    XCTAssertEqual(commonHeaders.count, paramsCount,
                   "Headers size should be \(paramsCount) but were \(commonHeaders.count)")
    XCTAssertEqual(acceptType?.value, MediaType.urlEncoded.value,
                   "Accept header should be \(MediaType.json.value) but was \(acceptType!.value)")
    XCTAssertEqual(contentType?.value, MediaType.urlEncoded.value,
                   "Content-type header should be \(MediaType.urlEncoded.value) but was \(contentType!.value)")
    XCTAssertEqual(authorization?.value, self.authorization.header().value,
                   "Authorization header should be \(self.authorization.header().value) but was \(String(describing: authorization?.value))")
    XCTAssertNotNil(userAgent, "User-agent header should not be nil")
  }
  
  func testCommonHeaders_withDeleteHTTPMethod_shouldContainExpectedParams() {
    let commonHeaders = requestHelper.commonHeaders(httpMethod: .delete)
    
    let userAgent = commonHeaders.first { $0.key == HTTPHeader.Constant.userAgent }
    let authorization = commonHeaders.first { $0.key == HTTPHeader.Constant.authorization }
    let acceptType = commonHeaders.first { $0.key == HTTPHeader.Constant.acceptType }
    let contentType = commonHeaders.first { $0.key == HTTPHeader.Constant.contentType }
    XCTAssertEqual(commonHeaders.count, paramsCount,
                   "Headers size should be \(paramsCount) but were \(commonHeaders.count)")
    XCTAssertEqual(acceptType?.value, MediaType.json.value,
                   "Accept header should be \(MediaType.json.value) but was \(acceptType!.value)")
    XCTAssertEqual(contentType?.value, MediaType.urlEncoded.value,
                   "Content-type header should be \(MediaType.urlEncoded.value) but was \(contentType!.value)")
    XCTAssertEqual(authorization?.value, self.authorization.header().value,
                   "Authorization header should be \(self.authorization.header().value) but was \(String(describing: authorization?.value))")
    XCTAssertNotNil(userAgent, "User-agent header should not be nil")
  }
  
  func testCommonHeaders_withPutHTTPMethod_shouldContainExpectedParams() {
    let commonHeaders = requestHelper.commonHeaders(httpMethod: .put)
    
    let userAgent = commonHeaders.first { $0.key == HTTPHeader.Constant.userAgent }
    let authorization = commonHeaders.first { $0.key == HTTPHeader.Constant.authorization }
    let acceptType = commonHeaders.first { $0.key == HTTPHeader.Constant.acceptType }
    let contentType = commonHeaders.first { $0.key == HTTPHeader.Constant.contentType }
    XCTAssertEqual(commonHeaders.count, paramsCount,
                   "Headers size should be \(paramsCount) but were \(commonHeaders.count)")
    XCTAssertEqual(acceptType?.value, MediaType.json.value,
                   "Accept header should be \(MediaType.json.value) but was \(acceptType!.value)")
    XCTAssertEqual(contentType?.value, MediaType.urlEncoded.value,
                   "Content-type header should be \(MediaType.urlEncoded.value) but was \(contentType!.value)")
    XCTAssertEqual(authorization?.value, self.authorization.header().value,
                   "Authorization header should be \(self.authorization.header().value) but was \(String(describing: authorization?.value))")
    XCTAssertNotNil(userAgent, "User-agent header should not be nil")
  }
}
