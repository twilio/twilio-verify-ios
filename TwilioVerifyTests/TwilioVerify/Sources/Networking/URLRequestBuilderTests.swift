//
//  URLRequestBuilderTests.swift
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

// swiftlint:disable force_cast
class URLRequestBuilderTests: XCTestCase {
  
  private var authorization: BasicAuthorization!
  private var requestHelper: RequestHelper!
  
  override func setUpWithError() throws {
    authorization = BasicAuthorization(username: "username", password: "password")
    requestHelper = RequestHelper(authorization: authorization)
  }

  func testInitializingRequest_withInvalidURL_shouldThrow() {
    XCTAssertThrowsError(try URLRequestBuilder(withURL: "", requestHelper: requestHelper).build(),
                         "Initializing URLRequestBuilder should throw") { error in
      XCTAssertEqual((error as! NetworkError).errorDescription, NetworkError.invalidURL.errorDescription)
    }
  }

  func testBuildURLRequest_withouthCustomHeaders_shouldMathExpectedParams() {
    var request: URLRequest!
    let httpMethod = HTTPMethod.get
    XCTAssertNoThrow(request = try URLRequestBuilder(withURL: Constants.url, requestHelper: requestHelper).setHTTPMethod(httpMethod).build(),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(request.url?.absoluteString, Constants.url,
                   "URL should be \(Constants.url) but was \(String(describing: request.url?.absoluteString))")
    XCTAssertEqual(request.httpMethod, httpMethod.value,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    let commonHeaders = requestHelper.commonHeaders(httpMethod: httpMethod)
    XCTAssertEqual(request.allHTTPHeaderFields?.count, commonHeaders.count,
                   "Headers count should be \(commonHeaders.count) but was \(String(describing: request.allHTTPHeaderFields?.count))")
    requestHelper.commonHeaders(httpMethod: httpMethod).forEach {
      XCTAssertEqual(request.allHTTPHeaderFields?[$0.key], $0.value,
                     "Header for key \($0.key) should be \($0.value) but was \(String(describing: request.allHTTPHeaderFields?[$0.key]))")
    }
  }
  
  func testBuildURLRequest_withCustomHeaders_shouldMathExpectedParams() {
    let customHeaders = [HTTPHeader(key: "Teletubbie1", value: "Tinky-Winky"),
                        HTTPHeader(key: "Teletubbie2", value: "Dipsy"),
                        HTTPHeader(key: "Teletubbie3", value: "Laa Laa"),
                        HTTPHeader(key: "Teletubbie4", value: "Po")]
    var request: URLRequest!
    let httpMethod = HTTPMethod.get
    XCTAssertNoThrow(request = try URLRequestBuilder(withURL: Constants.url,
                                                     requestHelper: requestHelper).setHTTPMethod(httpMethod).setHeaders(customHeaders).build(),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(request.url?.absoluteString, Constants.url,
                   "URL should be \(Constants.url) but was \(String(describing: request.url?.absoluteString))")
    XCTAssertEqual(request.httpMethod, httpMethod.value,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    let commonHeaders = requestHelper.commonHeaders(httpMethod: httpMethod)
    XCTAssertEqual(request.allHTTPHeaderFields?.count, commonHeaders.count + customHeaders.count,
                   "Headers count should be \(commonHeaders.count) but was \(String(describing: request.allHTTPHeaderFields?.count))")
    requestHelper.commonHeaders(httpMethod: httpMethod).forEach {
      XCTAssertEqual(request.allHTTPHeaderFields?[$0.key], $0.value,
                     "Header for key \($0.key) should be \($0.value) but was \(String(describing: request.allHTTPHeaderFields?[$0.key]))")
    }
  }
  
  func testRequestBody_withPostHTTPMethodAndURLEncodedHeader_shouldBeParamsAsString() {
    let customHeaders = [HTTPHeader.contentType(MediaType.urlEncoded.value)]
    let key1 = Constants.key1
    let value1 = "^&\(Constants.value1)"
    let key2 = Constants.key2
    let value2 = Constants.value2
    let parameters = [Parameter.init(name: key1, value: value1), Parameter.init(name: key2, value: value2)]
    let expectedBody = "\(key1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")" +
                       "=\(value1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")" +
                       "&\(key2.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")" +
                       "=\(String(value2).addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")"
    let httpMethod = HTTPMethod.post
    var request: URLRequest!
    XCTAssertNoThrow(request = try URLRequestBuilder(withURL: Constants.url,
                                                     requestHelper: requestHelper).setHTTPMethod(httpMethod).setHeaders(customHeaders).setParameters(parameters).build(),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(request.url?.absoluteString, Constants.url,
                   "URL should be \(Constants.url) but was \(String(describing: request.url?.absoluteString))")
    XCTAssertEqual(request.httpMethod, httpMethod.value,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    let body = request.httpBody
    XCTAssertNotNil(body, "Body should not be nil")
    XCTAssertEqual(String(decoding: body!, as: UTF8.self), expectedBody,
                   "Body should be \(expectedBody) but was \(String(decoding: body!, as: UTF8.self))")
  }
  
  func testRequestBody_withPostHTTPMethodAndJSONHeader_shouldBeParamsAsData() {
    let customHeaders = [HTTPHeader.contentType(MediaType.json.value)]
    let key1 = Constants.key1
    let value1 = "^&\(Constants.value1)"
    let key2 = Constants.key2
    let value2 = Constants.value2
    let parameters = [Parameter.init(name: key1, value: value1), Parameter.init(name: key2, value: value2)]
    let httpMethod = HTTPMethod.post
    var request: URLRequest!
    XCTAssertNoThrow(request = try URLRequestBuilder(withURL: Constants.url,
                                                     requestHelper: requestHelper).setHTTPMethod(httpMethod).setParameters(parameters).setHeaders(customHeaders).build(),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(request.url?.absoluteString, Constants.url,
                   "URL should be \(Constants.url) but was \(String(describing: request.url?.absoluteString))")
    XCTAssertEqual(request.httpMethod, httpMethod.value,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    XCTAssertNotNil(request.httpBody, "Body should not be nil")
    var body: [String: Any]!
    XCTAssertNoThrow(body = try JSONSerialization.jsonObject(with: request.httpBody!, options: []) as? [String: Any], "Casting to JSON should not throw")
    parameters.forEach {
      XCTAssertTrue(body.keys.contains($0.name), "Body should contains \($0.name)")
    }
  }
  
  func testRequestBody_withoutParameters_shouldBeEmpty() {
    let httpMethod = HTTPMethod.post
    var request: URLRequest!
    XCTAssertNoThrow(request = try URLRequestBuilder(withURL: Constants.url, requestHelper: requestHelper).setHTTPMethod(httpMethod).build(),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(request.url?.absoluteString, Constants.url,
                   "URL should be \(Constants.url) but was \(String(describing: request.url?.absoluteString))")
    XCTAssertEqual(request.httpMethod, httpMethod.value,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    XCTAssertNotNil(request.httpBody, "Body should not be nil")
    XCTAssertEqual(String(decoding: request.httpBody!, as: UTF8.self), "", "Body should be empty")
  }
  
  func testRequestBody_withParameters_shouldBeAppendedToURL() {
    let key1 = Constants.key1
    let value1 = "^&\(Constants.value1)"
    let key2 = Constants.key2
    let value2 = Constants.value2
    let parameters = [Parameter.init(name: key1, value: value1), Parameter.init(name: key2, value: value2)]
    let expectedQuery = "\(key1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")" +
                        "=\(value1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")" +
                        "&\(key2.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")" +
                        "=\(String(value2).addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")"
    let expectedURL = "\(Constants.url)?\(expectedQuery)"
    let httpMethod = HTTPMethod.get
    var request: URLRequest!
    XCTAssertNoThrow(request = try URLRequestBuilder(withURL: Constants.url, requestHelper: requestHelper).setHTTPMethod(httpMethod).setParameters(parameters).build(),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(request.httpMethod, httpMethod.value,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    XCTAssertNil(request.httpBody, "Body should be nil")
    XCTAssertEqual(request.url?.absoluteString, expectedURL,
                   "URL should be \(expectedURL) but was \(String(describing: request.url?.absoluteString))")
  }
  
  func testCreateURLRequestBuilder_withAppendedParametersToURL_shouldEncodeURL() {
    let key1 = "<.>\(Constants.key1)"
    let value1 = "^&\(Constants.value1)"
    let key2 = Constants.key2
    let value2 = "+_\(Constants.value2)"
    let query = "\(key1)=\(value1)&\(key2)=\(value2)"
    let url = "%?\(query)"
    let expectedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let httpMethod = HTTPMethod.get
    var request: URLRequest!
    XCTAssertNoThrow(request = try URLRequestBuilder(withURL: url, requestHelper: requestHelper).setHTTPMethod(httpMethod).build(),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(request.httpMethod, httpMethod.value,
                   "HTTP method should be \(httpMethod.value) but was \(request.httpMethod!))")
    XCTAssertNil(request.httpBody, "Body should be nil")
    XCTAssertEqual(request.url?.absoluteString, expectedURL,
                   "URL should be \(expectedURL) but was \(request.url!.absoluteString))")
  }
  
  func testCreateURLRequestBuilder_withInvalidURL_shouldThrowInvalidURL() {
    XCTAssertThrowsError(try URLRequestBuilder(withURL: "", requestHelper: requestHelper).build(),
                     "Initializing URLRequestBuilder should throw")
  }
}

private extension URLRequestBuilderTests {
  struct Constants {
    static let url = "https://twilio.com"
    static let key1 = "key1"
    static let key2 = "key2"
    static let value1 = "value1"
    static let value2 = 12345
  }
}
