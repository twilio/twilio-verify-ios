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
  private var challengeFacade: ChallengeFacadeMock!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    factorFacade = FactorFacadeMock()
    challengeFacade = ChallengeFacadeMock()
    twilioVerify = TwilioVerifyManager(factorFacade: factorFacade, challengeFacade: challengeFacade)
  }
  
  func testCreateFactor_withFactorResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    factorFacade.factor = Constants.expectedFactor
    var factorResponse: Factor!
    twilioVerify.createFactor(withPayload: Constants.factorPayload, success: { factor in
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
    twilioVerify.createFactor(withPayload: Constants.factorPayload, success: { factor in
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
    let factorPayload = VerifyPushFactorPayload(sid: "sid")
    factorFacade.factor = Constants.expectedFactor
    var factorResponse: Factor!
    twilioVerify.verifyFactor(withPayload: factorPayload, success: { factor in
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
  
  func testVerifyFactor_withErrorResponse_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let factorPayload = VerifyPushFactorPayload(sid: "sid")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.verifyFactor(withPayload: factorPayload, success: { factor in
      XCTFail()
      failureExpectation.fulfill()
    }) { failure in
      error = failure
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription, "Error should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
  
  func testDeleteFactor_withSuccessResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testDeleteFactor_withSuccessResponse_shouldSucceed")
    twilioVerify.deleteFactor(withSid: Constants.factorSid, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testDeleteFactor_withErrorResponse_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withErrorResponse_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.deleteFactor(withSid: Constants.factorSid, success: {
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testGetChallenge_withSuccessResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testGetChallenge_withSuccessResponse_shouldSucceed")
    challengeFacade.challenge = Constants.expectedChallenge
    var challenge: Challenge!
    twilioVerify.getChallenge(challengeSid: Constants.challengeSid, factorSid: Constants.expectedFactor.sid, success: { response in
      challenge = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(challenge.sid, Constants.expectedChallenge.sid,
                   "Challenge sid should be \(Constants.expectedChallenge.sid) but was \(challenge.sid)")
    XCTAssertEqual(challenge.hiddenDetails, Constants.expectedChallenge.hiddenDetails,
                   "Challenge hiddenDetails should be \(Constants.expectedChallenge.hiddenDetails) but was \(challenge.hiddenDetails)")
    XCTAssertEqual(challenge.factorSid, Constants.expectedChallenge.factorSid,
                   "Challenge factorSid should be \(Constants.expectedChallenge.factorSid) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.status, Constants.expectedChallenge.status,
                   "Challenge status should be \(Constants.expectedChallenge.status) but was \(challenge.status)")
    XCTAssertEqual(challenge.createdAt, Constants.expectedChallenge.createdAt,
                   "Challenge createdAt should be \(Constants.expectedChallenge.createdAt) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, Constants.expectedChallenge.updatedAt,
                   "Challenge updatedAt should be \(Constants.expectedChallenge.updatedAt) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.expirationDate, Constants.expectedChallenge.expirationDate,
                   "Challenge expirationDate should be \(Constants.expectedChallenge.expirationDate) but was \(challenge.expirationDate)")
    XCTAssertEqual(challenge.challengeDetails.message, Constants.expectedChallenge.challengeDetails.message,
                   "Challenge challengeDetails should be \(Constants.expectedChallenge.challengeDetails) but was \(challenge.challengeDetails)")
  }
  
  func testGetChallenge_withErrorResponse_shouldFail() {
    let expectation = self.expectation(description: "testGetChallenge_withErrorResponse_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    challengeFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.getChallenge(challengeSid: Constants.challengeSid, factorSid: Constants.expectedFactor.sid, success: { _ in
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdateChallenge_withSuccessResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testUpdateChallenge_withSuccessResponse_shouldSucceed")
    twilioVerify.updateChallenge(withPayload: Constants.updatePushChallengePayload, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testUpdateChallenge_withErrorResponse_shouldFail() {
    let expectation = self.expectation(description: "testUpdateChallenge_withErrorResponse_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    challengeFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.updateChallenge(withPayload: Constants.updatePushChallengePayload, success: {
      expectation.fulfill()
      XCTFail()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testGetAllChallenges_withValidData_shouldSucceed() {
    let expectation = self.expectation(description: "testGetAllChallenges_withValidData_shouldSucceed")
    challengeFacade.challengeList = Constants.expectedChallengeList
    var challengeList: ChallengeList!
    twilioVerify.getAllChallenges(withPayload: Constants.challengeListPayload, success: { result in
      challengeList = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(challengeList.challenges.count, Constants.expectedChallengeList.challenges.count,
                   "Challenge list should be \(Constants.expectedChallengeList.challenges) but were \(challengeList.challenges)")
    
  }
  
  func testGetAllChallenges_withFailureResponse_shouldFail() {
    let expectation = self.expectation(description: "testGetAllChallenges_withFailureResponse_shouldFail")
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    challengeFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.getAllChallenges(withPayload: Constants.challengeListPayload, success: { _ in
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

private extension TwilioVerifyManagerTests {
  struct Constants {
    static let factorSid = "factorSid123"
    static let friendlyName = "friendlyName123"
    static let serviceSid = "serviceSid123"
    static let identity = "identityValue"
    static let pushToken = "ACBtoken"
    static let enrollmentJWE = "jwe"
    static let challengeSid = "challengeSid"
    static let challengeSid2 = "challengeSid2"
    static let expectedFactor = PushFactor(
      sid: factorSid,
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      entityIdentity: "entityIdentity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"))
    static let factorPayload = PushFactorPayload(
      friendlyName: Constants.friendlyName,
      serviceSid: Constants.serviceSid,
      identity: Constants.identity,
      pushToken: Constants.pushToken,
      enrollmentJwe: Constants.enrollmentJWE)
    static let expectedChallenge = FactorChallenge(
      sid: challengeSid,
      challengeDetails: ChallengeDetails(message: "message", fields: [], date: Date()),
      hiddenDetails: "hiddenDetails",
      factorSid: factorSid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: expectedFactor)
    static let expectedChallenge2 = FactorChallenge(
      sid: challengeSid2,
      challengeDetails: ChallengeDetails(message: "message", fields: [], date: Date()),
      hiddenDetails: "hiddenDetails",
      factorSid: factorSid,
      status: .approved,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: expectedFactor)
    static let updatePushChallengePayload = UpdatePushChallengePayload(
      factorSid: factorSid,
      challengeSid: challengeSid,
      status: .approved)
    static let challengeListPayload = ChallengeListPayload(
      factorSid: factorSid,
      pageSize: 1)
    static let expectedChallengeList = FactorChallengeList(
      challenges: [expectedChallenge, expectedChallenge2],
      metadata: ChallengeListMetadata(page: 1, pageSize: 1, previousPageToken: nil, nextPageToken: nil))
  }
}
