//
//  FactorAPIClientTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/4/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class FactorAPIClientTests: XCTestCase {
  
  private var factorAPIClient: FactorAPIClient!
  private var networkProvider: NetworkProviderMock!
  private var authentication: AuthenticationMock!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    networkProvider = NetworkProviderMock()
    authentication = AuthenticationMock()
    factorAPIClient = FactorAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: Constants.baseURL)
  }
  
  func testCreateFactor_withSuccessResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse = "{\"key\":\"value\"}".data(using: .utf8)!
    networkProvider.response = Response(data: expectedResponse, headers: [:])
    let createFactorPayload = CreateFactorPayload(friendlyName: Constants.friendlyName, type: Constants.factorType,
                                                  serviceSid: Constants.serviceSid, entity: Constants.entity,
                                                  config: [:], binding: [:], jwe: Constants.jwe)
    factorAPIClient.create(withPayload: createFactorPayload, success: { response in
      XCTAssertEqual(response.data, expectedResponse, "Response should be \(expectedResponse) but was \(response.data)")
      successExpectation.fulfill()
    }) { error in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
  }
  
  func testCreateFactor_withError_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedError = TestError.operationFailed
    networkProvider.error = expectedError
    let createFactorPayload = CreateFactorPayload(friendlyName: Constants.friendlyName, type: Constants.factorType,
                                                  serviceSid: Constants.serviceSid, entity: Constants.entity,
                                                  config: [:], binding: [:], jwe: Constants.jwe)
    factorAPIClient.create(withPayload: createFactorPayload, success: { response in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual(error as! TestError, expectedError)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testCreateFactor_withInvalidURL_shouldFail() {
    factorAPIClient = FactorAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: "%")
    let failureExpectation = expectation(description: "Wait for failure response")
    let createFactorPayload = CreateFactorPayload(friendlyName: Constants.friendlyName, type: Constants.factorType,
                                                  serviceSid: Constants.serviceSid, entity: Constants.entity,
                                                  config: [:], binding: [:], jwe: Constants.jwe)
    factorAPIClient.create(withPayload: createFactorPayload, success: { response in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual((error as! NetworkError).errorDescription, NetworkError.invalidURL.errorDescription)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testCreateFactor_withValidData_shouldMatchExpectedParams() {
    let expectedURL = "\(Constants.baseURL)\(FactorAPIClient.Constants.createFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: Constants.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: Constants.entity)
    let binding = ["public_key": "12345"]
    let bindingString = String(data: try! JSONEncoder().encode(binding), encoding: .utf8)
    let config = ["sdk_version": "1.0.0", "app_id": "TwilioVerify",
                  "notification_platform": "apn", "notification_token": "pushToken"]
    let configString = String(data: try! JSONEncoder().encode(config), encoding: .utf8)
    let expectedParams = [Parameter(name: FactorAPIClient.Constants.friendlyNameKey, value: Constants.friendlyName),
                          Parameter(name: FactorAPIClient.Constants.factorTypeKey, value: Constants.factorType.rawValue),
                          Parameter(name: FactorAPIClient.Constants.bindingKey, value: bindingString!),
                          Parameter(name: FactorAPIClient.Constants.configKey, value: configString!)]
    var params = Parameters()
    params.addAll(expectedParams)
    let createFactorPayload = CreateFactorPayload(friendlyName: Constants.friendlyName, type: Constants.factorType,
                                                  serviceSid: Constants.serviceSid, entity: Constants.entity,
                                                  config: config, binding: binding, jwe: Constants.jwe)
    
    factorAPIClient.create(withPayload: createFactorPayload, success: {_ in }, failure: {_ in })
    
    XCTAssertEqual(networkProvider.urlRequest!.url!.absoluteString, expectedURL,
                   "URL should be \(expectedURL) but was \(networkProvider.urlRequest!.url!.absoluteString)")
    XCTAssertEqual(networkProvider.urlRequest!.httpMethod, HTTPMethod.post.value,
                   "HTTP method should be \(HTTPMethod.post.value) but was \(networkProvider.urlRequest!.httpMethod!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType], MediaType.urlEncoded.value,
                   "Content type should be \(MediaType.urlEncoded.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType]!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType], MediaType.json.value,
                   "Accept type should be \(MediaType.json.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType]!)")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.authorization],
                    "Authorization header should not be nil")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.userAgent],
                    "User agent header should not be nil")
    XCTAssertEqual(String(decoding: networkProvider.urlRequest!.httpBody!, as: UTF8.self), params.asString(),
                   "Body should be \(params.asString()) but was \(networkProvider.urlRequest!.httpBody!)")
  }
  
  func testVerifyFactor_withSuccessResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse = "{\"key\":\"value\"}".data(using: .utf8)!
    networkProvider.response = Response(data: expectedResponse, headers: [:])
    let factor = PushFactor(
      sid: Constants.factorSid,
      friendlyName: Constants.friendlyName,
      accountSid: Constants.accountSid,
      serviceSid: Constants.serviceSid,
      entityIdentity: Constants.entity,
      createdAt: Date(),
      config: Config(credentialSid: Constants.credentialSid))
    
    factorAPIClient.verify(factor, authPayload: Constants.authPayload, success: { response in
      XCTAssertEqual(response.data, expectedResponse, "Response should be \(expectedResponse) but was \(response.data)")
      successExpectation.fulfill()
    }) { error in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
  }
  
  func testVerifyFactor_withError_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedError = TestError.operationFailed
    networkProvider.error = expectedError
    let factor = PushFactor(
      sid: Constants.factorSid,
      friendlyName: Constants.friendlyName,
      accountSid: Constants.accountSid,
      serviceSid: Constants.serviceSid,
      entityIdentity: Constants.entity,
      createdAt: Date(),
      config: Config(credentialSid: Constants.credentialSid))
    
    factorAPIClient.verify(factor, authPayload: Constants.authPayload, success: { response in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual(error as! TestError, expectedError)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testVerifyFactor_withInvalidURL_shouldFail() {
    factorAPIClient = FactorAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: "%")
    let failureExpectation = expectation(description: "Wait for failure response")
    let factor = PushFactor(
      sid: Constants.factorSid,
      friendlyName: Constants.friendlyName,
      accountSid: Constants.accountSid,
      serviceSid: Constants.serviceSid,
      entityIdentity: Constants.entity,
      createdAt: Date(),
      config: Config(credentialSid: Constants.credentialSid))
    factorAPIClient.verify(factor, authPayload: Constants.authPayload, success: { response in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual((error as! NetworkError).errorDescription, NetworkError.invalidURL.errorDescription)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testVerifyFactor_withValidData_shouldMatchExpectedParams() {
    var expectedParams = Parameters()
    expectedParams.addAll([Parameter(name: FactorAPIClient.Constants.authPayloadKey, value: Constants.authPayload)])
    let factor = PushFactor(
      sid: Constants.factorSid,
      friendlyName: Constants.friendlyName,
      accountSid: Constants.accountSid,
      serviceSid: Constants.serviceSid,
      entityIdentity: Constants.entity,
      createdAt: Date(),
      config: Config(credentialSid: Constants.credentialSid))
    
    let expectedURL = "\(Constants.baseURL)\(FactorAPIClient.Constants.verifyFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: factor.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: factor.entityIdentity)
      .replacingOccurrences(of: APIConstants.factorSidPath, with: factor.sid)
    
    factorAPIClient.verify(factor, authPayload: Constants.authPayload, success: {_ in }, failure: {_ in })
    
    XCTAssertEqual(networkProvider.urlRequest!.url!.absoluteString, expectedURL,
                   "URL should be \(expectedURL) but was \(networkProvider.urlRequest!.url!.absoluteString)")
    XCTAssertEqual(networkProvider.urlRequest!.httpMethod, HTTPMethod.post.value,
                   "HTTP method should be \(HTTPMethod.post.value) but was \(networkProvider.urlRequest!.httpMethod!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType], MediaType.urlEncoded.value,
                   "Content type should be \(MediaType.urlEncoded.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType]!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType], MediaType.json.value,
                   "Accept type should be \(MediaType.json.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType]!)")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.authorization],
                    "Authorization header should not be nil")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.userAgent],
                    "User agent header should not be nil")
    XCTAssertEqual(String(decoding: networkProvider.urlRequest!.httpBody!, as: UTF8.self), expectedParams.asString(),
                   "Body should be \(expectedParams.asString()) but was \(networkProvider.urlRequest!.httpBody!)")
  }
}

extension FactorAPIClientTests {
  struct Constants {
    static let factorSid = "sid"
    static let friendlyName = "factor name"
    static let serviceSid = "serviceSid123"
    static let accountSid = "accountSid123"
    static let entity = "entityIdentity"
    static let credentialSid = "credentialSid123"
    static let factorType = FactorType.push
    static let jwe = "jwe"
    static let authPayload = "authPayload"
    static let baseURL = "https://twilio.com/"
  }
}
