//
//  TwilioVerifyManagerTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/23/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class TwilioVerifyManagerTests: XCTestCase {

  private var twilioVerify: TwilioVerify!
  private var factorFacade: FactorFacadeMock!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    factorFacade = FactorFacadeMock()
    twilioVerify = TwilioVerifyManager(factorFacade: factorFacade)
  }
  
  func testCreateFactor_withFactorResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    factorFacade.factor = Constants.expectedFactor
    var factorResponse: Factor!
    twilioVerify.createFactor(withInput: Constants.factorInput, success: { factor in
      factorResponse = factor
      successExpectation.fulfill()
    }) { failure in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertEqual(factorResponse.sid, Constants.expectedFactor.sid,
                   "Factor sid should be \(Constants.expectedFactor.sid) but was \(factorResponse.sid)")
    XCTAssertEqual(factorResponse.friendlyName, Constants.expectedFactor.friendlyName,
                   "Factor friendlyName should be \(Constants.expectedFactor.friendlyName) but was \(factorResponse.friendlyName)")
    XCTAssertEqual(factorResponse.accountSid, Constants.expectedFactor.accountSid,
                   "Factor accountSid should be \(Constants.expectedFactor.accountSid) but was \(factorResponse.accountSid)")
    XCTAssertEqual(factorResponse.serviceSid, Constants.expectedFactor.serviceSid,
                   "Factor serviceSid should be \(Constants.expectedFactor.serviceSid) but was \(factorResponse.serviceSid)")
    XCTAssertEqual(factorResponse.entityIdentity, Constants.expectedFactor.entityIdentity,
                   "Factor entityIdentity should be \(Constants.expectedFactor.entityIdentity) but was \(factorResponse.entityIdentity)")
    XCTAssertEqual(factorResponse.createdAt, Constants.expectedFactor.createdAt,
                   "Factor createdAt should be \(Constants.expectedFactor.createdAt) but was \(factorResponse.createdAt)")
  }
  
  func testCreateFactor_withErrorResponse_shouldFail(){
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.createFactor(withInput: Constants.factorInput, success: { factor in
      XCTFail()
      failureExpectation.fulfill()
    }) { failure in
      error = failure
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription, "Error should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
  
  func testVerifyFactor_withFactorResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let factorInput = VerifyPushFactorInput(sid: "sid")
    factorFacade.factor = Constants.expectedFactor
    var factorResponse: Factor!
    twilioVerify.verifyFactor(withInput: factorInput, success: { factor in
      factorResponse = factor
      successExpectation.fulfill()
    }) { failure in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertEqual(factorResponse.sid, Constants.expectedFactor.sid,
                   "Factor sid should be \(Constants.expectedFactor.sid) but was \(factorResponse.sid)")
    XCTAssertEqual(factorResponse.friendlyName, Constants.expectedFactor.friendlyName,
                   "Factor friendlyName should be \(Constants.expectedFactor.friendlyName) but was \(factorResponse.friendlyName)")
    XCTAssertEqual(factorResponse.accountSid, Constants.expectedFactor.accountSid,
                   "Factor accountSid should be \(Constants.expectedFactor.accountSid) but was \(factorResponse.accountSid)")
    XCTAssertEqual(factorResponse.serviceSid, Constants.expectedFactor.serviceSid,
                   "Factor serviceSid should be \(Constants.expectedFactor.serviceSid) but was \(factorResponse.serviceSid)")
    XCTAssertEqual(factorResponse.entityIdentity, Constants.expectedFactor.entityIdentity,
                   "Factor entityIdentity should be \(Constants.expectedFactor.entityIdentity) but was \(factorResponse.entityIdentity)")
    XCTAssertEqual(factorResponse.createdAt, Constants.expectedFactor.createdAt,
                   "Factor createdAt should be \(Constants.expectedFactor.createdAt) but was \(factorResponse.createdAt)")
  }
  
  func testVerifyFactor_withErrorReponse_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let factorInput = VerifyPushFactorInput(sid: "sid")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.verifyFactor(withInput: factorInput, success: { factor in
      XCTFail()
      failureExpectation.fulfill()
    }) { failure in
      error = failure
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription, "Error should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
}

private extension TwilioVerifyManagerTests {
  struct Constants {
    static let friendlyName = "friendlyName123"
    static let serviceSid = "serviceSid123"
    static let identity = "identityValue"
    static let pushToken = "ACBtoken"
    static let enrollmentJWE = "jwe"
    static let expectedFactor = PushFactor(
      sid: "sid",
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      entityIdentity: "entityIdentity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"))
    static let factorInput = PushFactorInput(
      friendlyName: Constants.friendlyName,
      serviceSid: Constants.serviceSid,
      identity: Constants.identity,
      pushToken: Constants.pushToken,
      enrollmentJwe: Constants.enrollmentJWE)
  }
}
