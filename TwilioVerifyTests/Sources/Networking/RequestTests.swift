//
//  RequestTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/1/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class RequestTests: XCTestCase {
  
  private var authorization: BasicAuthorization!
  private var requestHelper: RequestHelper!
  
  override func setUpWithError() throws {
    authorization = BasicAuthorization(username: "username", password: "password")
    requestHelper = RequestHelper(authorization: authorization)
  }

  func testInitializingRequest_withInvalidURL_shouldThrow() {
    XCTAssertThrowsError(try URLRequestBuilder().build(requestHelper: requestHelper, url: ""),"Initializing URLRequestBuilder should throw") { error in
      XCTAssertEqual(NetworkError.invalidURL, error as! NetworkError)
    }
  }

  func testBuildURLRequest_withouthCustomHeaders_shouldMathExpectedParams() {
    let url = "https://twilio.com"
    var request: URLRequest!
    let httpMethod = HTTPMethod.get
    let requestBuilder = URLRequestBuilder().httpMethod(httpMethod)
    XCTAssertNoThrow(request = try requestBuilder.build(requestHelper: requestHelper, url: url),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(url, request.url?.absoluteString,
                   "URL should be \(url) but was \(String(describing: request.url?.absoluteString))")
    XCTAssertEqual(httpMethod.value, request.httpMethod,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    let commonHeaders = requestHelper.commonHeaders(httpMethod: httpMethod)
    XCTAssertEqual(commonHeaders.count, request.allHTTPHeaderFields?.count,
                   "Headers count should be \(commonHeaders.count) but was \(String(describing: request.allHTTPHeaderFields?.count))")
    requestHelper.commonHeaders(httpMethod: httpMethod).forEach {
      XCTAssertEqual($0.value, request.allHTTPHeaderFields?[$0.name],
                     "Header for key \($0.name) should be \($0.value) but was \(String(describing: request.allHTTPHeaderFields?[$0.name]))")
    }
  }
  
  func testBuildURLRequest_withCustomHeaders_shouldMathExpectedParams() {
    let url = "https://twilio.com"
    let customHeaders = [HTTPHeader(name: "Teletubbie1", value: "Tinky-Winky"),
                        HTTPHeader(name: "Teletubbie2", value: "Dipsy"),
                        HTTPHeader(name: "Teletubbie3", value: "Laa Laa"),
                        HTTPHeader(name: "Teletubbie4", value: "Po")]
    var request: URLRequest!
    let httpMethod = HTTPMethod.get
    let requestBuilder = URLRequestBuilder().httpMethod(httpMethod).headers(customHeaders)
    XCTAssertNoThrow(request = try requestBuilder.build(requestHelper: requestHelper, url: url),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(url, request.url?.absoluteString,
                   "URL should be \(url) but was \(String(describing: request.url?.absoluteString))")
    XCTAssertEqual(httpMethod.value, request.httpMethod,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    let commonHeaders = requestHelper.commonHeaders(httpMethod: httpMethod)
    XCTAssertEqual(commonHeaders.count + customHeaders.count, request.allHTTPHeaderFields?.count,
                   "Headers count should be \(commonHeaders.count) but was \(String(describing: request.allHTTPHeaderFields?.count))")
    requestHelper.commonHeaders(httpMethod: httpMethod).forEach {
      XCTAssertEqual($0.value, request.allHTTPHeaderFields?[$0.name],
                     "Header for key \($0.name) should be \($0.value) but was \(String(describing: request.allHTTPHeaderFields?[$0.name]))")
    }
  }
  
  func testRequestBody_withPostHTTPMethodAndURLEncodedHeader_shouldBeParamsAsString() {
    let url = "https://twilio.com"
    let customHeaders = [HTTPHeader.contentType(MediaType.urlEncoded.value)]
    let key1 = "key1"
    let value1 = "^&value1"
    let key2 = "key2"
    let value2 = 12345
    let parameters = [Parameter.init(name: key1, value: value1), Parameter.init(name: key2, value: value2)]
    let expectedBody = "\(key1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")=\(value1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")&\(key2.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")=\(String(value2).addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")"
    let httpMethod = HTTPMethod.post
    var request: URLRequest!
    let requestBuilder = URLRequestBuilder().httpMethod(httpMethod).headers(customHeaders).parameters(parameters)
    XCTAssertNoThrow(request = try requestBuilder.build(requestHelper: requestHelper, url: url),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(url, request.url?.absoluteString,
                   "URL should be \(url) but was \(String(describing: request.url?.absoluteString))")
    XCTAssertEqual(httpMethod.value, request.httpMethod,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    let body = request.httpBody
    XCTAssertNotNil(body, "Body should not be nil")
    XCTAssertEqual(expectedBody, String(decoding: body!, as: UTF8.self),
                   "Body should be \(expectedBody) but was \(String(decoding: body!, as: UTF8.self))")
  }
  
  func testRequestBody_withPostHTTPMethodAndJSONHeader_shouldBeParamsAsData() {
    let url = "https://twilio.com"
    let customHeaders = [HTTPHeader.contentType(MediaType.json.value)]
    let key1 = "key1"
    let value1 = "^&value1"
    let key2 = "key2"
    let value2 = 12345
    let parameters = [Parameter.init(name: key1, value: value1), Parameter.init(name: key2, value: value2)]
    let httpMethod = HTTPMethod.post
    var request: URLRequest!
    let requestBuilder = URLRequestBuilder().httpMethod(httpMethod).parameters(parameters).headers(customHeaders)
    XCTAssertNoThrow(request = try requestBuilder.build(requestHelper: requestHelper, url: url),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(url, request.url?.absoluteString,
                   "URL should be \(url) but was \(String(describing: request.url?.absoluteString))")
    XCTAssertEqual(httpMethod.value, request.httpMethod,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    XCTAssertNotNil(request.httpBody, "Body should not be nil")
    var body: [String: Any]!
    XCTAssertNoThrow(body = try JSONSerialization.jsonObject(with: request.httpBody!, options: []) as? [String: Any], "Casting to JSON should not throw")
    parameters.forEach {
      XCTAssertTrue(body.keys.contains($0.name), "Body should contains \($0.name)")
    }
  }
  
  func testRequestBody_withoutParameters_shouldBeEmpty() {
    let url = "https://twilio.com"
    let httpMethod = HTTPMethod.post
    var request: URLRequest!
    let requestBuilder = URLRequestBuilder().httpMethod(httpMethod)
    XCTAssertNoThrow(request = try requestBuilder.build(requestHelper: requestHelper, url: url),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(url, request.url?.absoluteString,
                   "URL should be \(url) but was \(String(describing: request.url?.absoluteString))")
    XCTAssertEqual(httpMethod.value, request.httpMethod,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    XCTAssertNotNil(request.httpBody, "Body should not be nil")
    XCTAssertEqual("", String(decoding: request.httpBody!, as: UTF8.self), "Body should be empty")
  }
  
  func testRequestBody_withoutParameters_shouldBeAppendedToURL() {
    let url = "https://twilio.com"
    let key1 = "key1"
    let value1 = "^&value1"
    let key2 = "key2"
    let value2 = 12345
    let parameters = [Parameter.init(name: key1, value: value1), Parameter.init(name: key2, value: value2)]
    let expectedQuery = "\(key1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")=\(value1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")&\(key2.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")=\(String(value2).addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")"
    let expectedURL = "\(url)?\(expectedQuery)"
    let httpMethod = HTTPMethod.get
    var request: URLRequest!
    let requestBuilder = URLRequestBuilder().httpMethod(httpMethod).parameters(parameters)
    XCTAssertNoThrow(request = try requestBuilder.build(requestHelper: requestHelper, url: url),
                     "Initializing URLRequestBuilder should not throw")
    XCTAssertEqual(httpMethod.value, request.httpMethod,
                   "HTTP method should be \(httpMethod.value) but was \(String(describing: request.httpMethod))")
    XCTAssertNil(request.httpBody, "Body should be nil")
    XCTAssertEqual(expectedURL, request.url?.absoluteString,
                   "URL should be \(expectedURL) but was \(String(describing: request.url?.absoluteString))")
  }
}
