//
//  ChallengeFacadeTests.swift
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

// swiftlint:disable type_body_length
class ChallengeFacadeTests: XCTestCase {
  
  var pushChallengeProcessor: PushChallengeProcessorMock!
  var factorFacade: FactorFacadeMock!
  var repository: ChallengeProviderMock!
  var challengeFacade: ChallengeFacadeProtocol!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    pushChallengeProcessor = PushChallengeProcessorMock()
    factorFacade = FactorFacadeMock()
    repository = ChallengeProviderMock()
    challengeFacade = ChallengeFacade(pushChallengeProcessor: pushChallengeProcessor, factorFacade: factorFacade, repository: repository)
  }
  
  func testGetChallenge_withValidData_shouldSucceed() {
    let expectation = self.expectation(description: "testGetChallenge_withValidData_shouldSucceed")
    factorFacade.factor = Constants.expectedFactor
    pushChallengeProcessor.challenge = Constants.expectedChallenge
    pushChallengeProcessor.expectedFactor = Constants.expectedFactor
    pushChallengeProcessor.expectedSid = Constants.challengeSid
    var challenge: Challenge!
    challengeFacade.get(withSid: Constants.challengeSid, withFactorSid: Constants.factorSid, success: { result in
      challenge = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(challenge.sid, Constants.expectedChallenge.sid,
                   "Challenge should be \(Constants.expectedChallenge) but was \(challenge!)")
  }
  
  func testGetChallenge_withInvalidSID_shouldFail() {
    let expectation = expectation(description: .init())
    let expectedError: TwilioVerifyError = .inputError(
      error: InputError.emptyChallengeSid 
    )
    var errorRetrieved: TwilioVerifyError?
    
    challengeFacade.get(
      withSid: .init(),
      withFactorSid: Constants.factorSid,
      success: { _ in XCTFail() },
      failure: { errorResponse in
        errorRetrieved = errorResponse
        expectation.fulfill()
    })
      
    wait(for: [expectation], timeout: 3)
    
    XCTAssertEqual(
      errorRetrieved?.localizedDescription,
      expectedError.localizedDescription
    )
    
    XCTAssertEqual(
      errorRetrieved?.code,
      expectedError.code
    )
    
    XCTAssertEqual(
      errorRetrieved?.originalError.toEquatableError(),
      expectedError.originalError.toEquatableError()
    )
  }
  
  func testGetChallenge_withFailureResponse_shouldFail() {
    let expectation = self.expectation(description: "testGetChallenge_withFailureResponse_shouldFail")
    factorFacade.factor = Constants.expectedFactor
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed)
    pushChallengeProcessor.error = expectedError
    var error: TwilioVerifyError!
    challengeFacade.get(withSid: Constants.challengeSid, withFactorSid: Constants.factorSid, success: { _ in
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
  
  func testGetChallenge_withErrorGettingFactor_shouldFail() {
    let expectation = self.expectation(description: "testGetChallenge_withErrorGettingFactor_shouldFail")
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    challengeFacade.get(withSid: Constants.challengeSid, withFactorSid: Constants.factorSid, success: { _ in
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
  
  func testGetChallenge_withInvalidFactorType_shouldFail() {
    let expectation = self.expectation(description: "testGetChallenge_withInvalidFactorType_shouldFail")
    factorFacade.factor = Constants.fakeFactor
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput(field: "invalid factor") )
    var error: TwilioVerifyError!
    challengeFacade.get(withSid: Constants.challengeSid, withFactorSid: Constants.factorSid, success: { _ in
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
  
  func testUpdateChallenge_withValidData_shouldSucced() {
    let expectation = self.expectation(description: "testUpdateChallenge_withValidData_shouldSucced")
    factorFacade.factor = Constants.expectedFactor
    pushChallengeProcessor.challenge = Constants.expectedChallenge
    pushChallengeProcessor.expectedFactor = Constants.expectedFactor
    pushChallengeProcessor.expectedSid = Constants.challengeSid
    challengeFacade.update(withPayload: Constants.updatePushChallengePayload, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testUpdateChallenge_withFailureResponse_shouldFail() {
    let expectation = self.expectation(description: "testUpdateChallenge_withFailureResponse_shouldFail")
    factorFacade.factor = Constants.expectedFactor
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed)
    pushChallengeProcessor.error = expectedError
    var error: TwilioVerifyError!
    challengeFacade.update(withPayload: Constants.updatePushChallengePayload, success: {
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
  
  func testUpdateChallenge_withErrorGettingFactor_shouldFail() {
    let expectation = self.expectation(description: "testUpdateChallenge_withErrorGettingFactor_shouldFail")
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    challengeFacade.update(withPayload: Constants.updatePushChallengePayload, success: {
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
  
  func testUpdateChallenge_withInvalidFactorType_shouldFail() {
    let expectation = self.expectation(description: "testUpdateChallenge_withInvalidFactorType_shouldFail")
    factorFacade.factor = Constants.fakeFactor
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput(field: "invalid factor") )
    var error: TwilioVerifyError!
    challengeFacade.update(withPayload: Constants.updatePushChallengePayload, success: {
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)

    XCTAssertEqual(
      error.code,
      expectedError.code,
      "Error code should be \(expectedError.code) but was \(error.code)"
    )

    XCTAssertEqual(
      error.localizedDescription,
      expectedError.localizedDescription,
      "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)"
    )

    XCTAssertEqual(
      error.originalError.toEquatableError(),
      expectedError.originalError.toEquatableError(),
      "Original error should be \(expectedError.originalError) but was \(error.originalError)"
    )
  }
  
  func testUpdateChallenge_withInvalidPayload_shouldFail() {
    let expectation = self.expectation(description: "testUpdateChallenge_withInvalidPayload_shouldFail")
    factorFacade.factor = Constants.expectedFactor
    let expectedError = TwilioVerifyError.inputError(
      error: InputError.invalidUpdateChallengePayload(
        factorType: .push
      ) 
    )
    var error: TwilioVerifyError!
    challengeFacade.update(withPayload: Constants.fakeUpdateChallengePayload, success: {
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
    factorFacade.factor = Constants.expectedFactor
    repository.challengeList = Constants.expectedChallengeList
    var challengeList: ChallengeList!
    challengeFacade.getAll(withPayload: Constants.challengeListPayload, success: { result in
      challengeList = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(challengeList.challenges.count, Constants.expectedChallengeList.challenges.count,
                   "Challenge list should be \(Constants.expectedChallengeList.challenges) but were \(challengeList.challenges)")
    XCTAssertEqual(challengeList.metadata.page, Constants.expectedChallengeList.metadata.page,
                   "Metadata page should be \(Constants.expectedChallengeList.metadata.page) but was \(challengeList.metadata.page)")
    XCTAssertEqual(challengeList.metadata.pageSize, Constants.expectedChallengeList.metadata.pageSize,
                   "Metadata page size should be \(Constants.expectedChallengeList.metadata.pageSize) but was \(challengeList.metadata.pageSize)")
  }
  
  func testGetAllChallenges_withErrorGettingFactor_shouldFail() {
    let expectation = self.expectation(description: "testGetAllChallenges_withErrorGettingFactor_shouldFail")
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed)
    factorFacade.error = expectedError
    var error: TwilioVerifyError!
    challengeFacade.getAll(withPayload: Constants.challengeListPayload, success: { _ in
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
  
  func testGetAllChallenges_withFailureResponse_shouldFail() {
    let expectation = self.expectation(description: "testGetAllChallenges_withFailureResponse_shouldFail")
    factorFacade.factor = Constants.expectedFactor
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed)
    repository.error = expectedError
    var error: TwilioVerifyError!
    challengeFacade.getAll(withPayload: Constants.challengeListPayload, success: { _ in
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

private extension ChallengeFacadeTests {
  struct Constants {
    static let challengeSid = "challengeSid123"
    static let factorSid = "factorSid123"
    static let fakeFactor = FakeFactor(
      status: .verified,
      sid: factorSid,
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      type: .push, createdAt: Date())
    static let expectedFactor = PushFactor(
      sid: factorSid,
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      allowIphoneMigration: false,
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"))
    static let expectedChallenge = FactorChallenge(
      sid: challengeSid,
      challengeDetails: ChallengeDetails(message: "message", fields: [], date: Date()),
      hiddenDetails: ["key": "value"],
      factorSid: factorSid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: expectedFactor)
    static let updatePushChallengePayload = UpdatePushChallengePayload(
      factorSid: factorSid,
      challengeSid: challengeSid,
      status: .pending)
    static let fakeUpdateChallengePayload = FakeUpdateChallengePayload(
      factorSid: factorSid,
      challengeSid: challengeSid)
    static let challengeListPayload = ChallengeListPayload(
      factorSid: factorSid,
      pageSize: 1)
    static let expectedChallengeList = FactorChallengeList(
      challenges: [expectedChallenge],
      metadata: ChallengeListMetadata(page: 1, pageSize: 1, previousPageToken: nil, nextPageToken: nil))
  }
}
