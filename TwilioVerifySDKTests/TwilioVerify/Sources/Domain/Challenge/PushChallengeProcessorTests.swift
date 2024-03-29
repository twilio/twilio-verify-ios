//
//  PushChallengeProcessorTests.swift
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

// swiftlint:disable type_body_length file_length
class PushChallengeProcessorTests: XCTestCase {
  
  var challengeProvider: ChallengeProviderMock!
  var jwtGenerator: JwtGeneratorMock!
  var pushChallengeProcessor: PushChallengeProcessor!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    challengeProvider = ChallengeProviderMock()
    jwtGenerator = JwtGeneratorMock()
    pushChallengeProcessor = PushChallengeProcessor(challengeProvider: challengeProvider, jwtGenerator: jwtGenerator)
  }
  
  func testGetChallenge_withInvalidInput_shouldFail() {
    let expectation = expectation(description: "testGetChallenge_withInvalidInput_shouldFail")
    let challengeProviderError = InputError.invalidInput(field: "field")
    let expectedError = TwilioVerifyError.inputError(error: challengeProviderError)
    var error: TwilioVerifyError!
    challengeProvider.error = challengeProviderError
    
    pushChallengeProcessor.getChallenge(
      withSid: Constants.sid,
      withFactor: Constants.factor,
      success: { _ in
        XCTFail()
        expectation.fulfill()
      }) { failureReason in
        error = failureReason
        expectation.fulfill()
      }
    
    waitForExpectations(timeout: 3, handler: nil)

    XCTAssertEqual(
      error.code,
      expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)"
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
  
  func testGetChallenge_withValidInput_shouldSucceed() {
    let expectation = self.expectation(description: "testGetChallenge_withValidInput_shouldSucceed")
    var challenge: Challenge!
    let expectedChallenge = ChallengeMock(
      sid: Constants.sid,
      factorSid: Constants.factorSid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: nil,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date())
    challengeProvider.challenge = expectedChallenge
    
    pushChallengeProcessor.getChallenge(withSid: Constants.sid, withFactor: Constants.factor, success: { result in
      challenge = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(challenge.sid, expectedChallenge.sid,
                   "Challenge sid should be \(expectedChallenge.sid) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, expectedChallenge.factorSid,
                   "Challenge factorSid should be \(expectedChallenge.factorSid) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.challengeDetails.message, expectedChallenge.challengeDetails.message,
                   "Challenge Details messade should be \(expectedChallenge.challengeDetails.message) but was \(challenge.challengeDetails.message)")
    for (i, detail) in challenge.challengeDetails.fields.enumerated() {
      XCTAssertEqual(detail.label, expectedChallenge.challengeDetails.fields[i].label,
                     "Challenge detail label should be \(expectedChallenge.challengeDetails.fields[i].label) but was \(detail.label)")
      XCTAssertEqual(detail.value, expectedChallenge.challengeDetails.fields[i].value,
                     "Challenge detail value should be \(expectedChallenge.challengeDetails.fields[i].value) but was \(detail.value)")
    }
    XCTAssertEqual(challenge.hiddenDetails, expectedChallenge.hiddenDetails,
                   "Challenge sid should be \(expectedChallenge.sid) but was \(challenge.sid)")
    XCTAssertEqual(challenge.status, expectedChallenge.status,
                   "Challenge status should be \(expectedChallenge.status) but was \(challenge.status)")
    XCTAssertEqual(challenge.createdAt, expectedChallenge.createdAt,
                   "Challenge creation date should be \(expectedChallenge.createdAt) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, expectedChallenge.updatedAt,
                   "Challenge update date should be \(expectedChallenge.updatedAt) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.expirationDate, expectedChallenge.expirationDate,
                   "Challenge expiration date should be \(expectedChallenge.expirationDate) but was \(challenge.expirationDate)")
    
  }
  
  func testUpdate_withValidData_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    challengeProvider.challenge = Constants.generateFactorChallenge()
    let challengeStatus = ChallengeStatus.approved
    challengeProvider.updatedChallenge = Constants.generateFactorChallenge(withStatus: challengeStatus)
    jwtGenerator.jwt = Constants.jwt
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: challengeStatus, success: {
      successExpectation.fulfill()
    }) { _ in
      XCTFail()
      successExpectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testUpdate_withNoUpdatingChallenge_shouldFail() {
    let expectation = expectation(description: .init())
    let expectedError: TwilioVerifyError = .inputError(
      error: InputError.notUpdatedChallenge 
    )

    var errorRetrieved: TwilioVerifyError?
    
    jwtGenerator.jwt = Constants.jwt
    challengeProvider.challenge = Constants.generateFactorChallenge()
    challengeProvider.updatedChallenge = Constants.generateFactorChallenge(
      withStatus: ChallengeStatus.expired
    )
    
    pushChallengeProcessor.updateChallenge(
      withSid: Constants.sid,
      withFactor: Constants.factor,
      status: ChallengeStatus.pending,
      success: { XCTFail() },
      failure: { error in
        errorRetrieved = error
        expectation.fulfill()
      }
    )
    
    wait(for: [expectation], timeout: 1)
    
    XCTAssertEqual(
      errorRetrieved?.code,
      expectedError.code
    )
    
    XCTAssertEqual(
      errorRetrieved?.localizedDescription,
      expectedError.localizedDescription
    )
    
    XCTAssertEqual(
      errorRetrieved?.originalError.toEquatableError(),
      expectedError.originalError.toEquatableError()
    )
  }
  
  func testUpdate_withExpiredChallenge_shouldFail() {
    let expectation = expectation(description: .init())
    let expectedError: TwilioVerifyError = .inputError(
      error: InputError.expiredChallenge 
    )

    var errorRetrieved: TwilioVerifyError?
    
    challengeProvider.challenge = Constants.generateFactorChallenge(withStatus: .expired)

    pushChallengeProcessor.updateChallenge(
      withSid: Constants.sid,
      withFactor: Constants.factor,
      status: ChallengeStatus.expired,
      success: { XCTFail() },
      failure: { error in
        errorRetrieved = error
        expectation.fulfill()
      }
    )
    
    wait(for: [expectation], timeout: 1)
    
    XCTAssertEqual(
      errorRetrieved?.code,
      expectedError.code
    )
    
    XCTAssertEqual(
      errorRetrieved?.localizedDescription,
      expectedError.localizedDescription
    )
    
    XCTAssertEqual(
      errorRetrieved?.originalError.toEquatableError(),
      expectedError.originalError.toEquatableError()
    )
  }
  
  func testUpdate_withChallengeAlreadyUpdated_shouldFail() {
    let expectation = expectation(description: .init())
    let expectedError: TwilioVerifyError = .inputError(
      error: InputError.alreadyUpdatedChallenge 
    )

    var errorRetrieved: TwilioVerifyError?
    
    challengeProvider.challenge = Constants.generateFactorChallenge(withStatus: .approved)
    
    pushChallengeProcessor.updateChallenge(
      withSid: Constants.sid,
      withFactor: Constants.factor,
      status: ChallengeStatus.approved,
      success: { XCTFail() },
      failure: { error in
        errorRetrieved = error
        expectation.fulfill()
      }
    )
    
    wait(for: [expectation], timeout: 1)
    
    XCTAssertEqual(
      errorRetrieved?.code,
      expectedError.code
    )
    
    XCTAssertEqual(
      errorRetrieved?.localizedDescription,
      expectedError.localizedDescription
    )
    
    XCTAssertEqual(
      errorRetrieved?.originalError.toEquatableError(),
      expectedError.originalError.toEquatableError()
    )
  }
  
  func testUpdate_withDifferentStatus_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    challengeProvider.challenge = Constants.generateFactorChallenge()
    challengeProvider.updatedChallenge = Constants.generateFactorChallenge(withStatus: .approved)
    jwtGenerator.jwt = Constants.jwt
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput(field: "field") )
    var error: TwilioVerifyError!
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .denied, success: {
      XCTFail()
      failureExpectation.fulfill()
    }) { failureReason in
      error = failureReason
      failureExpectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
  
  func testUpdate_withErrorResponse_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    challengeProvider.challenge = Constants.generateFactorChallenge()
    challengeProvider.errorUpdating = TestError.operationFailed
    jwtGenerator.jwt = Constants.jwt
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed)
    var error: TwilioVerifyError!
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .denied, success: {
      XCTFail()
      failureExpectation.fulfill()
    }) { failureReason in
      error = failureReason
      failureExpectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")

    XCTAssertEqual(
      error.originalError.toEquatableError(),
      expectedError.originalError.toEquatableError(),
      "Original error should be \(expectedError.originalError) but was \(error.originalError)"
    )
  }
  
  func testUpdate_withInvalidChallenge_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withInvalidChallenge_shouldFail")
    let challenge = ChallengeMock(
      sid: Constants.sid,
      factorSid: Constants.factorSid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: nil,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date())
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(
      error: InputError.invalidChallenge 
    )
    var error: TwilioVerifyError!
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .approved, success: {
      XCTFail()
      expectation.fulfill()
    }) { failureReason in
      error = failureReason
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError.toEquatableError(), expectedError.originalError.toEquatableError(),
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withInvalidFactor_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withInvalidFactor_shouldFail")
    let factor = FactorMock(
      status: .unverified,
      sid: Constants.factorSid,
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      type: .push,
      createdAt: Date())
    let challenge = FactorChallenge(
      sid: Constants.sid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: ["key": "value"],
      factorSid: factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: factor)
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(
      error: InputError.wrongFactor 
    )
    var error: TwilioVerifyError!
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .approved, success: {
      XCTFail()
      expectation.fulfill()
    }) { failureReason in
      error = failureReason
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError.toEquatableError(), expectedError.originalError.toEquatableError(),
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withInvalidAlias_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withInvalidAlias_shouldFail")
    let factor = PushFactor(
      status: .verified,
      sid: Constants.factorSid,
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"),
      keyPairAlias: nil)
    let challenge = FactorChallenge(
      sid: Constants.sid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: ["key": "value"],
      factorSid: factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: factor,
      signatureFields: Constants.signatureFields,
      response: Constants.response)
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.storageError(error: StorageError.error("Alias not found") )
    var error: TwilioVerifyError!
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: factor, status: .approved, success: {
      XCTFail()
      expectation.fulfill()
    }) { failureReason in
      error = failureReason
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError.toEquatableError(), expectedError.originalError.toEquatableError(),
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withNoSignatureFields_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withNoSignatureFields_shouldFail")
    let challenge = FactorChallenge(
      sid: Constants.sid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: ["key": "value"],
      factorSid: Constants.factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor,
      signatureFields: nil,
      response: Constants.response)
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(
      error: InputError.signatureFields 
    )
    var error: TwilioVerifyError!
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .approved, success: {
      XCTFail()
      expectation.fulfill()
    }) { failureReason in
      error = failureReason
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError.toEquatableError(), expectedError.originalError.toEquatableError(),
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withEmptySignatureFields_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withEmptySignatureFields_shouldFail")
    let challenge = FactorChallenge(
      sid: "sid123",
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: ["key": "value"],
      factorSid: Constants.factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor,
      signatureFields: [],
      response: Constants.response)
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(
      error: InputError.signatureFields 
    )
    var error: TwilioVerifyError!
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .approved, success: {
      XCTFail()
      expectation.fulfill()
    }) { failureReason in
      error = failureReason
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError.toEquatableError(), expectedError.originalError.toEquatableError(),
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withNoResponse_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withNoResponse_shouldFail")
    let challenge = FactorChallenge(
      sid: "sid123",
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: ["key": "value"],
      factorSid: Constants.factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor,
      signatureFields: Constants.signatureFields,
      response: nil)
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(
      error: InputError.signatureFields 
    )
    var error: TwilioVerifyError!
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .approved, success: {
      XCTFail()
      expectation.fulfill()
    }) { failureReason in
      error = failureReason
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")

    XCTAssertEqual(
      error.originalError.toEquatableError(),
      expectedError.originalError.toEquatableError(),
      "Original error should be \(expectedError.originalError) but was \(error.originalError)"
    )
  }
  
  func testUpdate_withEmptyResponse_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withEmptyResponse_shouldFail")
    let challenge = FactorChallenge(
      sid: "sid123",
      challengeDetails: ChallengeDetails(message: "message", fields: [Detail(label: "label", value: "value")], date: Date()),
      hiddenDetails: ["key": "value"],
      factorSid: Constants.factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor,
      signatureFields: Constants.signatureFields,
      response: [:])
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(
      error: InputError.signatureFields 
    )
    var error: TwilioVerifyError!
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .approved, success: {
      XCTFail()
      expectation.fulfill()
    }) { failureReason in
      error = failureReason
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")

    XCTAssertEqual(
      error.originalError.toEquatableError(),
      expectedError.originalError.toEquatableError(),
      "Original error should be \(expectedError.originalError) but was \(error.originalError)"
    )
  }
  
  func testUpdate_withResponseWithoutSignatureField_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withResponseWithoutSignatureField_shouldFail")
    let challenge = FactorChallenge(
      sid: "sid123",
      challengeDetails: ChallengeDetails(message: "message", fields: [Detail(label: "label", value: "value")], date: Date()),
      hiddenDetails: ["key": "value"],
      factorSid: Constants.factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor,
      signatureFields: ["sid", "factorSid"],
      response: ["sid": "sid123"])
    challengeProvider.challenge = challenge

    let expectedError = TwilioVerifyError.inputError(
      error: InputError.invalidInput(field: "value in response")
    )
    var error: TwilioVerifyError!

    pushChallengeProcessor.updateChallenge(
      withSid: Constants.sid,
      withFactor: Constants.factor,
      status: .approved,
      success: {
        XCTFail()
        expectation.fulfill()
      }) { failureReason in
        error = failureReason
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
  
  func testUpdate_withErrorGeneratingSignature_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withErrorGeneratingSignature_shouldFail")
    challengeProvider.challenge = Constants.generateFactorChallenge()
    jwtGenerator.error = JwtSignerError.invalidFormat
    let expectedError = TwilioVerifyError.inputError(error: JwtSignerError.invalidFormat )
    var error: TwilioVerifyError!
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .approved, success: {
      XCTFail()
      expectation.fulfill()
    }) { failureReason in
      error = failureReason
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")

    XCTAssertEqual(
      error.originalError.toEquatableError(),
      expectedError.originalError.toEquatableError(),
      "Original error should be \(expectedError.originalError) but was \(error.originalError)"
    )
  }
  
  func testUpdate_withValidData_shouldGenerateCorrectSignature() {
    let expectation = self.expectation(description: "testUpdate_withValidData_shouldGenerateCorrectSignature")
    challengeProvider.challenge = Constants.generateFactorChallenge()
    challengeProvider.updatedChallenge = Constants.generateFactorChallenge(withStatus: .approved)
    jwtGenerator.jwt = Constants.jwt
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .approved, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(jwtGenerator.header, [:], "Header should be empty but was \(jwtGenerator.header!)")
    XCTAssertEqual(NSDictionary(dictionary: jwtGenerator.payload), NSDictionary(dictionary: Constants.expectedPayload),
                   "Payload should be \(Constants.expectedPayload) but was \(jwtGenerator.payload!)")
  }
}

private extension PushChallengeProcessorTests {
  struct Constants {
    static let sid = "sid123"
    static let status: ChallengeStatus = .approved
    static let factorSid = "factorSid123"
    static let factor = PushFactor(
      status: .verified,
      sid: "factorSid123",
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"),
      keyPairAlias: "alias")
    static let challengeDetails = ChallengeDetails(
      message: "message",
      fields: [Detail(label: "label", value: "value")], date: Date())
    static let response = ["sid": sid, "factorSid": factorSid]
    static let signatureFields = Array(response.keys)
    static let expectedPayload = response.merging([PushChallengeProcessor.Constants.status: status.rawValue]) { $1 }
    static let jwt = "jwt"
    static func generateFactorChallenge(withStatus status: ChallengeStatus = .pending) -> FactorChallenge {
      FactorChallenge(
        sid: Constants.sid,
        challengeDetails: Constants.challengeDetails,
        hiddenDetails: ["key": "value"],
        factorSid: Constants.factor.sid,
        status: status,
        createdAt: Date(),
        updatedAt: Date(),
        expirationDate: Date(),
        factor: Constants.factor,
        signatureFields: Constants.signatureFields,
        response: Constants.response)
    }
  }
}
