//
//  ChallengeAPIClientTests.swift
//  TwilioVerifyTests
//
//  Created by Yeimi Moreno on 6/23/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class ChallengeAPIClientTests: XCTestCase {

  private var challengeAPIClient: ChallengeAPIClient!
  private var networkProvider: NetworkProviderMock!
  private var authentication: AuthenticationMock!

  override func setUpWithError() throws {
    try super.setUpWithError()
    networkProvider = NetworkProviderMock()
    authentication = AuthenticationMock()
    challengeAPIClient = ChallengeAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: Constants.baseURL)
  }
  
  func testGetChallenge_withSuccessResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse = "{\"key\":\"value\"}".data(using: .utf8)!
    let expectedHeaders = ["header": "value"]
    networkProvider.response = Response(data: expectedResponse, headers: expectedHeaders)
    let sid = "sid"
    var apiResponse: Response?
    challengeAPIClient.get(withSid: sid, withFactor: Constants.factor, success: { response in
      apiResponse = response
      successExpectation.fulfill()
    }) { error in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertEqual(apiResponse?.data, expectedResponse, "Response should be \(expectedResponse) but was \(apiResponse!.data)")
    XCTAssertEqual(apiResponse?.headers.count, expectedHeaders.count, "Headers count should be \(expectedHeaders.count) but was \(apiResponse!.headers.count)")
    XCTAssertEqual(apiResponse!.headers["header"] as! String, expectedHeaders["header"]!, "Header should be \(expectedHeaders["header"]!) but was \(apiResponse!.headers["header"]!)")
  }
  
  func testGetChallenge_withError_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedError = TestError.operationFailed
    networkProvider.error = expectedError
    let sid = "sid"
    var apiError: TestError?
    challengeAPIClient.get(withSid: sid, withFactor: Constants.factor, success: { response in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      apiError = error as? TestError
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual(apiError, expectedError)
  }
  
  func testGetChallenge_withInvalidURL_shouldFail() {
    challengeAPIClient = ChallengeAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: "%")
    let failureExpectation = expectation(description: "Wait for failure response")
    let sid = "sid"
    var apiError: NetworkError?
    challengeAPIClient.get(withSid: sid, withFactor: Constants.factor, success: { response in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      apiError = error as? NetworkError
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual(apiError?.errorDescription, NetworkError.invalidURL.errorDescription)
  }
  
  func testGetChallenge_withValidData_shouldMatchExpectedParams() {
    let sid = "sid"
    let expectedURL = "\(Constants.baseURL)\(ChallengeAPIClient.Constants.getChallengeURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: Constants.factor.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: Constants.factor.entityIdentity)
      .replacingOccurrences(of: APIConstants.challengeSidPath, with: sid)
    
    challengeAPIClient.get(withSid: sid, withFactor: Constants.factor, success: {_ in }, failure: {_ in })
    
    XCTAssertEqual(networkProvider.urlRequest!.url!.absoluteString, expectedURL,
                   "URL should be \(expectedURL) but was \(networkProvider.urlRequest!.url!.absoluteString)")
    XCTAssertEqual(networkProvider.urlRequest!.httpMethod, HTTPMethod.get.value,
                   "HTTP method should be \(HTTPMethod.post.value) but was \(networkProvider.urlRequest!.httpMethod!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType], MediaType.urlEncoded.value,
                   "Content type should be \(MediaType.urlEncoded.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType]!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType], MediaType.urlEncoded.value,
                   "Accept type should be \(MediaType.urlEncoded.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType]!)")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.authorization],
                    "Authorization header should not be nil")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.userAgent],
                    "User agent header should not be nil")
  }
  
  func testUpdateChallenge_withSuccessResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse = "{\"key\":\"value\"}".data(using: .utf8)!
    networkProvider.response = Response(data: expectedResponse, headers: [:])
    let challenge = FactorChallenge(
      sid: Constants.challengeSid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "",
      factorSid: Constants.factorSid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor)
    var apiResponse: Response?
    challengeAPIClient.update(challenge, withAuthPayload: Constants.authPayload, success: { response in
      apiResponse = response
      successExpectation.fulfill()
    }) { error in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertEqual(apiResponse?.data, expectedResponse, "Response should be \(expectedResponse) but was \(apiResponse!.data)")
  }
  
  func testUpdateChallenge_withError_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedError = TestError.operationFailed
    networkProvider.error = expectedError
    let challenge = FactorChallenge(
      sid: Constants.challengeSid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "",
      factorSid: Constants.factorSid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor)
    var apiError: TestError?
    challengeAPIClient.update(challenge, withAuthPayload: Constants.authPayload, success: { response in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      apiError = error as? TestError
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual(apiError, expectedError)
  }
  
  func testUpdateChallenge_withInvalidURL_shouldFail() {
    challengeAPIClient = ChallengeAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: "%")
    let failureExpectation = expectation(description: "Wait for failure response")
    let challenge = FactorChallenge(
      sid: Constants.challengeSid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "",
      factorSid: Constants.factorSid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor)
    var apiError: NetworkError?
    challengeAPIClient.update(challenge, withAuthPayload: Constants.authPayload, success: { response in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      apiError = error as? NetworkError
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual(apiError?.errorDescription, NetworkError.invalidURL.errorDescription)
  }
  
  func testUpdateChallenge_withNilFactor_shouldFail() {
    let expectation = self.expectation(description: "testUpdateChallenge_withNilFactor_shouldFail")
    let challenge = FactorChallenge(
      sid: Constants.challengeSid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "",
      factorSid: Constants.factorSid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date())
    var error: InputError!
    challengeAPIClient.update(challenge, withAuthPayload: Constants.authPayload, success: { response in
      XCTFail()
      expectation.fulfill()
    }) { failureReason in
      error = (failureReason as! InputError)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.errorDescription, InputError.invalidInput.errorDescription)
  }
  
  func testUpdateChallenge_withValidData_shouldMatchExpectedParams() {
    var expectedParams = Parameters()
    expectedParams.addAll([Parameter(name: FactorAPIClient.Constants.authPayloadKey, value: Constants.authPayload)])
    let challenge = FactorChallenge(
      sid: Constants.challengeSid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "",
      factorSid: Constants.factorSid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
    factor: Constants.factor)
    let expectedURL = "\(Constants.baseURL)\(ChallengeAPIClient.Constants.getChallengeURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: Constants.factor.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: Constants.factor.entityIdentity)
      .replacingOccurrences(of: APIConstants.challengeSidPath, with: challenge.sid)
    
    challengeAPIClient.update(challenge, withAuthPayload: Constants.authPayload, success: {_ in }, failure: {_ in })
    
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
  
  func testGetAll_withError_shouldFail() {
    let expectation = self.expectation(description: "testGetAll_withError_shouldFail")
    let expectedError = TestError.operationFailed
    networkProvider.error = expectedError
    var error: TestError!
    challengeAPIClient.getAll(forFactor: Constants.factor, status: nil, pageSize: 1, pageToken: nil, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { failureReson in
      error = (failureReson as! TestError)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error, expectedError)
  }
  
  func testGetAll_withInvalidURL_shouldFail() {
    challengeAPIClient = ChallengeAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: "%")
    let expectation = self.expectation(description: "testGetAll_withInvalidURL_shouldFail")
    var error: NetworkError!
    
    challengeAPIClient.getAll(forFactor: Constants.factor, status: nil, pageSize: 1, pageToken: nil, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { failureReason in
      error = failureReason as? NetworkError
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.errorDescription, NetworkError.invalidURL.errorDescription)
  }
  
  func testGetAll_withValidParametersWithoutStatusAndPageToken_shouldMatchExpectedParams() {
    let pageSize = 1
    var expectedParams = Parameters()
    expectedParams.addAll([Parameter(name: ChallengeAPIClient.Constants.factorSidKey, value: Constants.factor.sid),
                           Parameter(name: ChallengeAPIClient.Constants.pageSizeKey, value: pageSize)])
   
    let expectedURL = "\(Constants.baseURL)\(ChallengeAPIClient.Constants.getChallengesURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: Constants.factor.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: Constants.factor.entityIdentity)
    
    challengeAPIClient.getAll(forFactor: Constants.factor, status: nil, pageSize: pageSize, pageToken: nil, success: { _ in }) { _ in }
    let components = URLComponents(url: networkProvider.urlRequest!.url!, resolvingAgainstBaseURL: true)
    let queryParametersAsString = components!.queryItems!.map { $0.description }.joined(separator: "&")
    let requestURLWithoutQuery = networkProvider.urlRequest!.url!.absoluteString.split(separator: "?").map {String($0)}[0]
    XCTAssertEqual(requestURLWithoutQuery, expectedURL,
                   "URL should be \(expectedURL) but was \(requestURLWithoutQuery)")
    XCTAssertEqual(networkProvider.urlRequest!.httpMethod, HTTPMethod.get.value,
                   "HTTP method should be \(HTTPMethod.post.value) but was \(networkProvider.urlRequest!.httpMethod!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType], MediaType.urlEncoded.value,
                   "Content type should be \(MediaType.urlEncoded.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType]!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType], MediaType.urlEncoded.value,
                   "Accept type should be \(MediaType.json.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType]!)")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.authorization],
                    "Authorization header should not be nil")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.userAgent],
                    "User agent header should not be nil")
    
    XCTAssertEqual(queryParametersAsString, expectedParams.asString(),
                   "Query parameters should be \(expectedParams.asString()) but was \(queryParametersAsString)")
  }
  
  func testGetAll_withAllValidParameters_shouldMatchExpectedParams() {
    let pageSize = 1
    let status = FactorStatus.verified.rawValue
    let pageToken = "pageToken"
    var expectedParams = Parameters()
    expectedParams.addAll([Parameter(name: ChallengeAPIClient.Constants.factorSidKey, value: Constants.factor.sid),
                           Parameter(name: ChallengeAPIClient.Constants.pageSizeKey, value: pageSize),
                           Parameter(name: ChallengeAPIClient.Constants.statusKey, value: status),
                           Parameter(name: ChallengeAPIClient.Constants.pageTokenKey, value: pageToken)])
   
    let expectedURL = "\(Constants.baseURL)\(ChallengeAPIClient.Constants.getChallengesURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: Constants.factor.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: Constants.factor.entityIdentity)
    
    challengeAPIClient.getAll(forFactor: Constants.factor, status: status, pageSize: pageSize, pageToken: pageToken, success: { _ in }) { _ in }
    let components = URLComponents(url: networkProvider.urlRequest!.url!, resolvingAgainstBaseURL: true)
    let queryParametersAsString = components!.queryItems!.map { $0.description }.joined(separator: "&")
    let requestURLWithoutQuery = networkProvider.urlRequest!.url!.absoluteString.split(separator: "?").map {String($0)}[0]
    XCTAssertEqual(requestURLWithoutQuery, expectedURL,
                   "URL should be \(expectedURL) but was \(requestURLWithoutQuery)")
    XCTAssertEqual(networkProvider.urlRequest!.httpMethod, HTTPMethod.get.value,
                   "HTTP method should be \(HTTPMethod.post.value) but was \(networkProvider.urlRequest!.httpMethod!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType], MediaType.urlEncoded.value,
                   "Content type should be \(MediaType.urlEncoded.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.contentType]!)")
    XCTAssertEqual(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType], MediaType.urlEncoded.value,
                   "Accept type should be \(MediaType.json.value) but was \(networkProvider.urlRequest!.allHTTPHeaderFields![HTTPHeader.Constant.acceptType]!)")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.authorization],
                    "Authorization header should not be nil")
    XCTAssertNotNil(networkProvider.urlRequest?.allHTTPHeaderFields![HTTPHeader.Constant.userAgent],
                    "User agent header should not be nil")
    
    XCTAssertEqual(queryParametersAsString, expectedParams.asString(),
                   "Query parameters should be \(expectedParams.asString()) but was \(queryParametersAsString)")
  }
  
  func testGetAll_withSuccessResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testGetAll_withSuccessResponse_shouldSucceed")
    let expectedResponse = "{\"key\":\"value\"}".data(using: .utf8)!
    var response: Response!
    networkProvider.response = Response(data: expectedResponse, headers: [:])
    
    challengeAPIClient.getAll(forFactor: Constants.factor, status: nil, pageSize: 1, pageToken: nil, success: { result in
      response = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(response.data, expectedResponse, "Response should be \(expectedResponse) but was \(response.data)")
  }
}

extension ChallengeAPIClientTests {
  struct Constants {
    static let factorSid = "sid"
    static let friendlyName = "factor name"
    static let serviceSid = "serviceSid123"
    static let accountSid = "accountSid123"
    static let entity = "entityIdentity"
    static let credentialSid = "credentialSid123"
    static let challengeSid = "challengeSid123"
    static let challengeDetails = ChallengeDetails(message: "message", fields: [], date: Date())
    static let authPayload = "authPayload123"
    static let factorType = FactorType.push
    static let baseURL = "https://twilio.com/"
    static let factor = PushFactor(
      sid: Constants.factorSid,
      friendlyName: Constants.friendlyName,
      accountSid: Constants.accountSid,
      serviceSid: Constants.serviceSid,
      entityIdentity: Constants.entity,
      createdAt: Date(),
      config: Config(credentialSid: Constants.credentialSid)
    )
  }
}
