//
//  FactorAPIClientTests.swift
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

// swiftlint:disable force_cast type_body_length file_length
class FactorAPIClientTests: XCTestCase {
  
  private var factorAPIClient: FactorAPIClient!
  private var networkProvider: NetworkProviderMock!
  private var authentication: AuthenticationMock!
  private var dateProvider: DateProviderMock!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    networkProvider = NetworkProviderMock()
    authentication = AuthenticationMock()
    dateProvider = DateProviderMock()
    factorAPIClient = FactorAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: Constants.baseURL, dateProvider: dateProvider)
  }
  
  func testCreateFactor_withSuccessResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse = "{\"key\":\"value\"}".data(using: .utf8)!
    networkProvider.response = NetworkResponse(data: expectedResponse, headers: [:])
    let createFactorPayload = CreateFactorPayload(friendlyName: Constants.friendlyName, type: Constants.factorType,
                                                  serviceSid: Constants.serviceSid, identity: Constants.identity,
                                                  config: [:], binding: [:], accessToken: Constants.accessToken,
                                                  metadata: nil)
    factorAPIClient.create(withPayload: createFactorPayload, success: { response in
      XCTAssertEqual(response.data, expectedResponse, "Response should be \(expectedResponse) but was \(response.data)")
      successExpectation.fulfill()
    }) { _ in
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
                                                  serviceSid: Constants.serviceSid, identity: Constants.identity,
                                                  config: [:], binding: [:], accessToken: Constants.accessToken,
                                                  metadata: nil)
    factorAPIClient.create(withPayload: createFactorPayload, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual(error as! TestError, expectedError)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testCreateFactor_withValidData_shouldMatchExpectedParams() {
    let expectedURL = "\(Constants.baseURL)\(FactorAPIClient.Constants.createFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: Constants.serviceSid)
      .replacingOccurrences(of: APIConstants.identityPath, with: Constants.identity)
    let binding = ["public_key": "12345"]
    let config = ["sdk_version": "1.0.0", "app_id": "TwilioVerify",
                  "notification_platform": "apn", "notification_token": "pushToken"]
    var expectedParams = [Parameter(name: FactorAPIClient.Constants.friendlyNameKey, value: Constants.friendlyName),
                          Parameter(name: FactorAPIClient.Constants.factorTypeKey, value: Constants.factorType.rawValue)]
    expectedParams.append(contentsOf: binding.map { bindingPair in
      Parameter(name: "\(FactorAPIClient.Constants.bindingKey).\(bindingPair.key)", value: bindingPair.value)
    })
    expectedParams.append(contentsOf: config.map { configPair in
      Parameter(name: "\(FactorAPIClient.Constants.configKey).\(configPair.key)", value: configPair.value)
    })
    var params = Parameters()
    params.addAll(expectedParams)
    let createFactorPayload = CreateFactorPayload(friendlyName: Constants.friendlyName, type: Constants.factorType,
                                                  serviceSid: Constants.serviceSid, identity: Constants.identity,
                                                  config: config, binding: binding, accessToken: Constants.accessToken,
                                                  metadata: nil)
    
    factorAPIClient.create(withPayload: createFactorPayload, success: {_ in }, failure: {_ in })
    
    XCTAssertEqual(networkProvider.urlRequest?.url?.absoluteString, expectedURL,
                   "URL should be \(expectedURL) but was \(networkProvider.urlRequest?.url?.absoluteString)")
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
  
  func testCreateFactor_withMetadata_shouldMatchExpectedParams() {
    let expectedURL = "\(Constants.baseURL)\(FactorAPIClient.Constants.createFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: Constants.serviceSid)
      .replacingOccurrences(of: APIConstants.identityPath, with: Constants.identity)
    let binding = ["public_key": "12345"]
    let config = ["sdk_version": "1.0.0", "app_id": "TwilioVerify",
                  "notification_platform": "apn", "notification_token": "pushToken"]
    let metadata = ["os": "iOS", "device": "iPhone"]
    var expectedParams = [Parameter(name: FactorAPIClient.Constants.friendlyNameKey, value: Constants.friendlyName),
                          Parameter(name: FactorAPIClient.Constants.factorTypeKey, value: Constants.factorType.rawValue)]
    expectedParams.append(contentsOf: binding.map { bindingPair in
      Parameter(name: "\(FactorAPIClient.Constants.bindingKey).\(bindingPair.key)", value: bindingPair.value)
    })
    expectedParams.append(contentsOf: config.map { configPair in
      Parameter(name: "\(FactorAPIClient.Constants.configKey).\(configPair.key)", value: configPair.value)
    })
    var params = Parameters()
    var paramsv2 = Parameters()
    params.addAll(expectedParams)
    paramsv2.addAll(expectedParams)
    // Handle random metadata order
    params.addAll([Parameter(name: FactorAPIClient.Constants.metadataKey, value: "{\"os\":\"iOS\",\"device\":\"iPhone\"}")])
    paramsv2.addAll([Parameter(name: FactorAPIClient.Constants.metadataKey, value: "{\"device\":\"iPhone\",\"os\":\"iOS\"}")])
    let createFactorPayload = CreateFactorPayload(friendlyName: Constants.friendlyName, type: Constants.factorType,
                                                  serviceSid: Constants.serviceSid, identity: Constants.identity,
                                                  config: config, binding: binding, accessToken: Constants.accessToken,
                                                  metadata: metadata)
    
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
    XCTAssert(String(decoding: networkProvider.urlRequest!.httpBody!, as: UTF8.self) == params.asString() || String(decoding: networkProvider.urlRequest!.httpBody!, as: UTF8.self) == paramsv2.asString(),
                   "Body should be \(params.asString()) or \(paramsv2.asString()) but was \(String(decoding: networkProvider.urlRequest!.httpBody!, as: UTF8.self))")
  }
  
  func testVerifyFactor_withSuccessResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse = "{\"key\":\"value\"}".data(using: .utf8)!
    networkProvider.response = NetworkResponse(data: expectedResponse, headers: [:])
    factorAPIClient.verify(Constants.factor, authPayload: Constants.authPayload, success: { response in
      XCTAssertEqual(response.data, expectedResponse, "Response should be \(expectedResponse) but was \(response.data)")
      successExpectation.fulfill()
    }) { _ in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
  }
  
  func testVerifyFactor_withTimeOutOfSync_shouldSyncTimeAndRedoRequest() {
    let expectation = self.expectation(description: "testVerifyFactor_withTimeOutOfSync_shouldSyncTimeAndRedoRequest")
    let expectedError = NetworkError.failureStatusCode(failureResponse: Constants.failureResponse)
    let expectedResponse = NetworkResponse(data: "{\"key\":\"value\"}".data(using: .utf8)!, headers: [:])
    networkProvider.responses = [expectedError, expectedResponse]
    var response: NetworkResponse!
    factorAPIClient.verify(Constants.factor, authPayload: Constants.authPayload, success: { result in
      response = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(dateProvider.syncTimeCalled, "Sync time should be called")
    XCTAssertEqual(response.data, expectedResponse.data, "Response should be \(expectedResponse) but was \(response.data)")
  }
  
  func testVerifyFactor_withTimeOutOfSync_shouldRetryOnlyAnotherTime() {
    let expectation = self.expectation(description: "testVerifyFactor_withTimeOutOfSync_shouldRetryOnlyAnotherTime")
    let expectedError = NetworkError.failureStatusCode(failureResponse: Constants.failureResponse)
    networkProvider.error = expectedError
    factorAPIClient.verify(Constants.factor, authPayload: Constants.authPayload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { _ in
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(dateProvider.syncTimeCalled, "Sync time should be called")
    XCTAssertEqual(networkProvider.callsToExecute, BaseAPIClient.Constants.retryTimes + 1,
                   "Execute should be called \(BaseAPIClient.Constants.retryTimes + 1) times but was called \(networkProvider.callsToExecute) times")
  }
  
  func testVerifyFactor_withError_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedError = TestError.operationFailed
    networkProvider.error = expectedError
    factorAPIClient.verify(Constants.factor, authPayload: Constants.authPayload, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual(error as! TestError, expectedError)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testVerifyFactor_withValidData_shouldMatchExpectedParams() {
    var expectedParams = Parameters()
    expectedParams.addAll([Parameter(name: FactorAPIClient.Constants.authPayloadKey, value: Constants.authPayload)])
    let expectedURL = "\(Constants.baseURL)\(FactorAPIClient.Constants.verifyFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: Constants.factor.serviceSid)
      .replacingOccurrences(of: APIConstants.identityPath, with: Constants.factor.identity)
      .replacingOccurrences(of: APIConstants.factorSidPath, with: Constants.factor.sid)
    
    factorAPIClient.verify(Constants.factor, authPayload: Constants.authPayload, success: {_ in }, failure: {_ in })
    
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
  
  func testDeleteFactor_withSuccessResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testDeleteFactor_withSuccessResponse_shouldSucceed")
    let expectedURL = "\(Constants.baseURL)\(FactorAPIClient.Constants.verifyFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: Constants.factor.serviceSid)
      .replacingOccurrences(of: APIConstants.identityPath, with: Constants.factor.identity)
      .replacingOccurrences(of: APIConstants.factorSidPath, with: Constants.factor.sid)
    let expectedResponse = "{\"key\":\"value\"}".data(using: .utf8)!
    networkProvider.response = NetworkResponse(data: expectedResponse, headers: [:])
    factorAPIClient.delete(Constants.factor, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    
    XCTAssertEqual(networkProvider.urlRequest!.url!.absoluteString, expectedURL,
                   "URL should be \(expectedURL) but was \(networkProvider.urlRequest!.url!.absoluteString)")
    XCTAssertEqual(networkProvider.urlRequest!.httpMethod, HTTPMethod.delete.value,
                   "HTTP method should be \(HTTPMethod.delete.value) but was \(networkProvider.urlRequest!.httpMethod!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType], MediaType.urlEncoded.value,
                   "Content type should be \(MediaType.urlEncoded.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType]!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType], MediaType.json.value,
                   "Accept type should be \(MediaType.json.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType]!)")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.authorization],
                    "Authorization header should not be nil")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.userAgent],
                    "User agent header should not be nil")
  }
  
  func testDeleteFactor_withTimeOutOfSync_shouldSyncTimeAndRedoRequest() {
    let expectation = self.expectation(description: "testDeleteFactor_withTimeOutOfSync_shouldSyncTimeAndRedoRequest")
    let expectedError = NetworkError.failureStatusCode(failureResponse: Constants.failureResponse)
    let expectedResponse = NetworkResponse(data: "{\"key\":\"value\"}".data(using: .utf8)!, headers: [:])
    networkProvider.responses = [expectedError, expectedResponse]
    factorAPIClient.delete(Constants.factor, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(dateProvider.syncTimeCalled, "Sync time should be called")
  }
  
  func testDeleteFactor_withUnathorizedResponseCode_shouldRetryOnlyAnotherTimeAndCallSuccess() {
    let expectation = self.expectation(description: "testDeleteFactor_withUnathorizedResponseCode_shouldRetryOnlyAnotherTimeAndCallSuccess")
    let expectedError = NetworkError.failureStatusCode(failureResponse: Constants.failureResponse)
    networkProvider.error = expectedError
    factorAPIClient.delete(Constants.factor, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(dateProvider.syncTimeCalled, "Sync time should be called")
    XCTAssertEqual(networkProvider.callsToExecute, BaseAPIClient.Constants.retryTimes + 1,
                   "Execute should be called \(BaseAPIClient.Constants.retryTimes + 1) times but was called \(networkProvider.callsToExecute) times")
  }
  
  func testDeleteFactor_withNotFoundResponseCode_shouldCallSuccess() {
    let expectation = self.expectation(description: "testDeleteFactor_withNotFoundResponseCode_shouldCallSuccess")
    let failureResponse = FailureResponse(statusCode: 404,
                                          errorData: "error".data(using: .utf8)!,
                                          headers: [BaseAPIClient.Constants.dateHeaderKey: "Tue, 21 Jul 2020 17:07:32 GMT"])
    let expectedError = NetworkError.failureStatusCode(failureResponse: failureResponse)
    networkProvider.error = expectedError
    factorAPIClient.delete(Constants.factor, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testDeleteFactor_withFailureResponse_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withFailureResponse_shouldFail")
    let expectedError = TestError.operationFailed
    networkProvider.error = expectedError
    var error: Error!
    factorAPIClient.delete(Constants.factor, success: {
      expectation.fulfill()
      XCTFail()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual((error as! TestError), TestError.operationFailed,
                   "Error should be \(TestError.operationFailed) but was \(error!)")
  }
  
  func testUpdateFactor_withSuccessResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse = "{\"key\":\"value\"}".data(using: .utf8)!
    networkProvider.response = NetworkResponse(data: expectedResponse, headers: [:])
    factorAPIClient.update(Constants.factor, updateFactorDataPayload: Constants.updateFactorDataPayload, success: { response in
      XCTAssertEqual(response.data, expectedResponse, "Response should be \(expectedResponse) but was \(response.data)")
      successExpectation.fulfill()
    }) { _ in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
  }
  
  func testUpdateFactor_withTimeOutOfSync_shouldSyncTimeAndRedoRequest() {
    let expectation = self.expectation(description: "testUpdateFactor_withTimeOutOfSync_shouldSyncTimeAndRedoRequest")
    let expectedError = NetworkError.failureStatusCode(failureResponse: Constants.failureResponse)
    let expectedResponse = NetworkResponse(data: "{\"key\":\"value\"}".data(using: .utf8)!, headers: [:])
    networkProvider.responses = [expectedError, expectedResponse]
    var response: NetworkResponse!
    factorAPIClient.update(Constants.factor, updateFactorDataPayload: Constants.updateFactorDataPayload, success: { result in
      response = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(dateProvider.syncTimeCalled, "Sync time should be called")
    XCTAssertEqual(response.data, expectedResponse.data, "Response should be \(expectedResponse) but was \(response.data)")
  }
  
  func testUpdateFactor_withTimeOutOfSync_shouldRetryOnlyAnotherTime() {
    let expectation = self.expectation(description: "testUpdateFactor_withTimeOutOfSync_shouldRetryOnlyAnotherTime")
    let expectedError = NetworkError.failureStatusCode(failureResponse: Constants.failureResponse)
    networkProvider.error = expectedError
    factorAPIClient.update(Constants.factor, updateFactorDataPayload: Constants.updateFactorDataPayload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { _ in
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(dateProvider.syncTimeCalled, "Sync time should be called")
    XCTAssertEqual(networkProvider.callsToExecute, BaseAPIClient.Constants.retryTimes + 1,
                   "Execute should be called \(BaseAPIClient.Constants.retryTimes + 1) times but was called \(networkProvider.callsToExecute) times")
  }
  
  func testUpdateFactor_withError_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedError = TestError.operationFailed
    networkProvider.error = expectedError
    
    factorAPIClient.update(Constants.factor, updateFactorDataPayload: Constants.updateFactorDataPayload, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual(error as! TestError, expectedError)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testUpdateFactor_withValidData_shouldMatchExpectedParams() {
    var expectedParams = Parameters()
    expectedParams.addAll([Parameter(name: FactorAPIClient.Constants.friendlyNameKey, value: Constants.friendlyName)])
    expectedParams.addAll(Constants.config.map { configPair in
      Parameter(name: "\(FactorAPIClient.Constants.configKey).\(configPair.key)", value: configPair.value)
    })
    let expectedURL = "\(Constants.baseURL)\(FactorAPIClient.Constants.updateFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: Constants.factor.serviceSid)
      .replacingOccurrences(of: APIConstants.identityPath, with: Constants.factor.identity)
      .replacingOccurrences(of: APIConstants.factorSidPath, with: Constants.factor.sid)
    
    factorAPIClient.update(Constants.factor, updateFactorDataPayload: Constants.updateFactorDataPayload, success: {_ in }, failure: {_ in })
    
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
    static let identity = "identity"
    static let credentialSid = "credentialSid123"
    static let factorType = FactorType.push
    static let accessToken = "accessToken"
    static let authPayload = "authPayload"
    static let pushTokenKey = "notification_token"
    static let pushToken = "pushToken"
    static let config = [pushTokenKey: pushToken]
    static let updateFactorDataPayload = UpdateFactorDataPayload(
      friendlyName: friendlyName,
      type: factorType,
      serviceSid: serviceSid,
      identity: identity,
      config: config,
      factorSid: factorSid)
    static let baseURL = "https://twilio.com/"
    static let factor = PushFactor(
      sid: Constants.factorSid,
      friendlyName: Constants.friendlyName,
      accountSid: Constants.accountSid,
      serviceSid: Constants.serviceSid,
      identity: Constants.identity,
      createdAt: Date(),
      config: Config(credentialSid: Constants.credentialSid))
    static let failureResponse = FailureResponse(
      statusCode: 401,
      errorData: "error".data(using: .utf8)!,
      headers: [BaseAPIClient.Constants.dateHeaderKey: "Tue, 21 Jul 2020 17:07:32 GMT"])
  }
}
