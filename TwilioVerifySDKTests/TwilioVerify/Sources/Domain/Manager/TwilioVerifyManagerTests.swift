//
//  TwilioVerifyManagerTests.swift
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

// swiftlint:disable type_body_length file_length force_cast
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
    }) { _ in
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
    XCTAssertEqual(factorResponse.identity, Constants.expectedFactor.identity,
                   "Factor identity should be \(Constants.expectedFactor.identity) but was \(factorResponse.identity)")
    XCTAssertEqual(factorResponse.createdAt, Constants.expectedFactor.createdAt,
                   "Factor createdAt should be \(Constants.expectedFactor.createdAt) but was \(factorResponse.createdAt)")
  }
  
  func testCreateFactor_withErrorResponse_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.createFactor(withPayload: Constants.factorPayload, success: { _ in
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
    }) { _ in
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
    XCTAssertEqual(factorResponse.identity, Constants.expectedFactor.identity,
                   "Factor identity should be \(Constants.expectedFactor.identity) but was \(factorResponse.identity)")
    XCTAssertEqual(factorResponse.createdAt, Constants.expectedFactor.createdAt,
                   "Factor createdAt should be \(Constants.expectedFactor.createdAt) but was \(factorResponse.createdAt)")
  }
  
  func testVerifyFactor_withErrorResponse_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let factorPayload = VerifyPushFactorPayload(sid: "sid")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.verifyFactor(withPayload: factorPayload, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { failure in
      error = failure
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription, "Error should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
  
  func testUpdateFactor_withSuccessResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testUpdateFactor_withSuccessResponse_shouldSucceed")
    factorFacade.factor = Constants.expectedFactor
    var factor: Factor!
    twilioVerify.updateFactor(withPayload: Constants.updatePushFactorPayload, success: { response in
      factor = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(factor.sid, Constants.expectedFactor.sid,
                   "Factor sid should be \(Constants.expectedFactor.sid) but was \(factor.sid)")
    XCTAssertEqual(factor.friendlyName, Constants.expectedFactor.friendlyName,
                   "Factor friendlyName should be \(Constants.expectedFactor.friendlyName) but was \(factor.friendlyName)")
    XCTAssertEqual(factor.accountSid, Constants.expectedFactor.accountSid,
                   "Factor accountSid should be \(Constants.expectedFactor.accountSid) but was \(factor.accountSid)")
    XCTAssertEqual(factor.serviceSid, Constants.expectedFactor.serviceSid,
                   "Factor serviceSid should be \(Constants.expectedFactor.serviceSid) but was \(factor.serviceSid)")
    XCTAssertEqual(factor.identity, Constants.expectedFactor.identity,
                   "Factor identity should be \(Constants.expectedFactor.identity) but was \(factor.identity)")
    XCTAssertEqual(factor.createdAt, Constants.expectedFactor.createdAt,
                   "Factor createdAt should be \(Constants.expectedFactor.createdAt) but was \(factor.createdAt)")
  }
  
  func testUpdateFactor_withErrorResponse_shouldFail() {
    let expectation = self.expectation(description: "testUpdateFactor_withErrorResponse_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.updateFactor(withPayload: Constants.updatePushFactorPayload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
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
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed)
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
    XCTAssertEqual(error.originalError.toEquatableError(), expectedError.originalError.toEquatableError(),
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
                   "Challenge hiddenDetails should be \(Constants.expectedChallenge.hiddenDetails!) but was \(challenge.hiddenDetails!)")
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
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed)
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
    XCTAssertEqual(error.originalError.toEquatableError(), expectedError.originalError.toEquatableError(),
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
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed)
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
    XCTAssertEqual(error.originalError.toEquatableError(), expectedError.originalError.toEquatableError(),
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testGetAllFactors_withSuccessResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testGetAllFactors_withSuccessResponse_shouldSucceed")
    factorFacade.factor = Constants.expectedFactor
    var factors: [Factor]!
    twilioVerify.getAllFactors(success: { response in
      factors = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(factors.first?.sid, Constants.expectedFactor.sid, "Factor should be \(Constants.expectedFactor) but was \(factors.first!)")
  }
  
  func testGetAllFactors_withFAILUREResponse_shouldFail() {
    let expectation = self.expectation(description: "testGetAllFactors_withFAILUREResponse_shouldFail")
    factorFacade.factor = Constants.expectedFactor
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    twilioVerify.getAllFactors(success: { _ in
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
    XCTAssertEqual(error.originalError.toEquatableError(), expectedError.originalError.toEquatableError(),
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
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed)
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
  
  func testClearLocalStorage_withError_shouldThrow() {
    let expectedError = TwilioVerifyError.storageError(error: TestError.operationFailed)
    factorFacade.error = expectedError
    XCTAssertThrowsError(try twilioVerify.clearLocalStorage(), "Clear local storage should throw") { error in
      let error = error as! TwilioVerifyError
      XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                     "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
      XCTAssertEqual(error.originalError.toEquatableError(), expectedError.originalError.toEquatableError(),
                     "Original error should be \(expectedError.originalError) but was \(error.originalError)")
    }
  }
  
  func testClearLocalStorage_withoutError_shouldNotThrow() {
    XCTAssertNoThrow(try twilioVerify.clearLocalStorage(), "Clear local storage should not throw")
  }
}

private extension TwilioVerifyManagerTests {
  struct Constants {
    static let factorSid = "factorSid123"
    static let friendlyName = "friendlyName123"
    static let serviceSid = "serviceSid123"
    static let identity = "identityValue"
    static let pushToken = "ACBtoken"
    static let accessToken = "accessToken"
    static let challengeSid = "challengeSid"
    static let challengeSid2 = "challengeSid2"
    static let expectedFactor = PushFactor(
      sid: factorSid,
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"))
    static let factorPayload = PushFactorPayload(
      friendlyName: Constants.friendlyName,
      serviceSid: Constants.serviceSid,
      identity: Constants.identity,
      pushToken: Constants.pushToken,
      accessToken: Constants.accessToken)
    static let updatePushFactorPayload = UpdatePushFactorPayload(
      sid: Constants.factorSid,
      pushToken: Constants.pushToken)
    static let expectedChallenge = FactorChallenge(
      sid: challengeSid,
      challengeDetails: ChallengeDetails(message: "message", fields: [], date: Date()),
      hiddenDetails: ["key1": "value1"],
      factorSid: factorSid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: expectedFactor)
    static let expectedChallenge2 = FactorChallenge(
      sid: challengeSid2,
      challengeDetails: ChallengeDetails(message: "message", fields: [], date: Date()),
      hiddenDetails: ["key2": "value2"],
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
