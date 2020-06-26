//
//  PushChallengeProcessorTests.swift
//  TwilioVerifyTests
//
//  Created by Yeimi Moreno on 6/24/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

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
  
  func testUpdate_withInvalidChallenge_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withInvalidChallenge_shouldFail")
    let challenge = ChallengeMock(
      sid: Constants.sid,
      factorSid: Constants.factorSid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "",
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date())
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput as NSError)
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
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
      entityIdentity: "entityIdentity",
      type: .push,
      createdAt: Date())
    let challenge = FactorChallenge(
      sid: Constants.sid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "{\"key\":\"value\"}",
      factorSid: factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: factor)
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput as NSError)
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
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
      entityIdentity: "identity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"),
      keyPairAlias: nil)
    let challenge = FactorChallenge(
      sid: Constants.sid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "{\"key\":\"value\"}",
      factorSid: factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: factor,
      signatureFields: Constants.signatureFields,
      response: Constants.response)
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.storageError(error: StorageError.error("Alias not found") as NSError)
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withNoSignatureFields_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withNoSignatureFields_shouldFail")
    let challenge = FactorChallenge(
      sid: Constants.sid,
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "{\"key\":\"value\"}",
      factorSid: Constants.factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor,
      signatureFields: nil,
      response: Constants.response)
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput as NSError)
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withEmptySignatureFields_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withEmptySignatureFields_shouldFail")
    let challenge = FactorChallenge(
      sid: "sid123",
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "{\"key\":\"value\"}",
      factorSid: Constants.factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor,
      signatureFields: [],
      response: Constants.response)
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput as NSError)
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withNoResponse_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withNoResponse_shouldFail")
    let challenge = FactorChallenge(
      sid: "sid123",
      challengeDetails: Constants.challengeDetails,
      hiddenDetails: "{\"key\":\"value\"}",
      factorSid: Constants.factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor,
      signatureFields: Constants.signatureFields,
      response: nil)
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput as NSError)
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withEmptyResponse_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withEmptyResponse_shouldFail")
    let challenge = FactorChallenge(
      sid: "sid123",
      challengeDetails: ChallengeDetails(message: "message", fields: [Detail(label: "label", value: "value")], date: Date()),
      hiddenDetails: "{\"key\":\"value\"}",
      factorSid: Constants.factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor,
      signatureFields: Constants.signatureFields,
      response: [:])
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput as NSError)
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withResponseWithoutSignatureField_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withResponseWithoutSignatureField_shouldFail")
    let challenge = FactorChallenge(
      sid: "sid123",
      challengeDetails: ChallengeDetails(message: "message", fields: [Detail(label: "label", value: "value")], date: Date()),
      hiddenDetails: "{\"key\":\"value\"}",
      factorSid: Constants.factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: Constants.factor,
      signatureFields: ["sid", "factorSid"],
      response: ["sid": "sid123"])
    challengeProvider.challenge = challenge
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput as NSError)
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withErrorGeneratingSignature_shouldFail() {
    let expectation = self.expectation(description: "testUpdate_withErrorGeneratingSignature_shouldFail")
    challengeProvider.challenge = Constants.challenge
    jwtGenerator.error = JwtSignerError.invalidFormat
    let expectedError = TwilioVerifyError.inputError(error: JwtSignerError.invalidFormat as NSError)
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testUpdate_withValidData_shouldGenerateCorrectSignature() {
    let expectation = self.expectation(description: "testUpdate_withValidData_shouldGenerateCorrectSignature")
    challengeProvider.challenge = Constants.challenge
    jwtGenerator.jwt = Constants.jwt
    pushChallengeProcessor.updateChallenge(withSid: Constants.sid, withFactor: Constants.factor, status: .approved, success: {
      expectation.fulfill()
    }) { failureReason in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(jwtGenerator.header, [:], "Header should be empty but was \(jwtGenerator.header!)")
    XCTAssertEqual(NSDictionary(dictionary: jwtGenerator.payload), NSDictionary(dictionary:Constants.expectedPayload),
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
      entityIdentity: "identity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"),
      keyPairAlias: "alias")
    static let challengeDetails = ChallengeDetails(message: "message", fields: [Detail(label: "label", value: "value")], date: Date())
    static let response = ["sid": sid, "factorSid": factorSid]
    static let signatureFields = Array(response.keys)
    static let challenge = FactorChallenge(
      sid: sid,
      challengeDetails: challengeDetails,
      hiddenDetails: "{\"key\":\"value\"}",
      factorSid: factor.sid,
      status: .pending,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: factor,
      signatureFields: signatureFields,
      response: response)
    static let expectedPayload = response.merging([PushChallengeProcessor.Constants.status: status.rawValue]){ $1 }
    static let jwt = "jwt"
  }
}
