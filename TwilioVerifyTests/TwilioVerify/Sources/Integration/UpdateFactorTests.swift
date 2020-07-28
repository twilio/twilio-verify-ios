//
//  UpdateFactorTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 7/16/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class UpdateFactorTests: BaseFactorTests {

  func testUpdateFactor_withValidAPIResponse_ShouldReturnFactor() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.updateFactorValidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8) else {
        fatalError("verify_factor_valid_response.json not found")
    }
    let expectation = self.expectation(description: "testUpdateFactor_withValidAPIResponse_ShouldReturnFactor")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    var factorResponse: Factor!
    twilioVerify.updateFactor(withPayload: Constants.updateFactorPayload, success: { response in
      factorResponse = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(factorResponse is PushFactor, "Factor should be PushFactor")
    XCTAssertEqual(factorResponse.friendlyName, factor!.friendlyName,
                   "Factor friendly name should be \(factor!.friendlyName) but was \(factorResponse.friendlyName)")
    XCTAssertEqual(factorResponse.sid, factor!.sid,
                   "Factor sid should be \(factor!.sid) but was \(factorResponse.sid)")
    XCTAssertEqual(factorResponse.accountSid, factor!.accountSid,
                   "Factor account sid should be \(factor!.accountSid) but was \(factorResponse.accountSid)")
    XCTAssertEqual(factorResponse.type, factor!.type,
                   "Factor type should be \(factor!.type) but was \(factorResponse.type)")
    XCTAssertEqual(factorResponse.status.rawValue, FactorStatus.verified.rawValue,
                   "Factor status should be \(FactorStatus.verified.rawValue) but was \(factorResponse.status.rawValue)")
    XCTAssertEqual(factorResponse.entityIdentity, Constants.identity,
                   "Factor identity should be \(Constants.identity) but was \(factorResponse.entityIdentity)")
    XCTAssertEqual(factorResponse.serviceSid, Constants.serviceSid,
                   "Factor service sid should be \(Constants.serviceSid) but was \(factorResponse.serviceSid)")
  }
  
  func testUpdateFactor_withInvalidAPIResponseCode_shouldFail() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.updateFactorValidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8) else {
        fatalError("verify_factor_valid_response.json not found")
    }
    
    let expectation = self.expectation(description: "testUpdateFactor_withInvalidAPIResponseCode_shouldFail")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 400, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.updateFactor(withPayload: Constants.updateFactorPayload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
  
  func testUpdateFactor_withInvalidAPIResponseBody_shouldFail() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.updateFactorInvalidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8) else {
        fatalError("invalid_response.json not found")
    }
    
    let expectation = self.expectation(description: "testUpdateFactor_withInvalidAPIResponseBody_shouldFail")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.updateFactor(withPayload: Constants.updateFactorPayload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
}

private extension UpdateFactorTests {
  struct Constants {
    static let url = "https://twilio.com"
    static let accountSidKey = "account_sid"
    static let sidKey = "sid"
    static let factorStatusKey = "status"
    static let factorTypeKey = "factor_type"
    static let friendlyName = "friendlyName"
    static let identity = "identity"
    static let serviceSid = "serviceSid"
    static let updateFactorValidResponse = "verify_factor_valid_response"
    static let updateFactorInvalidResponse = "invalid_response"
    static let json = "json"
    static let updateFactorPayload = UpdatePushFactorPayload(sid: "factorSid", pushToken: "pushToken")
  }
}