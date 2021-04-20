//
//  ChallengeRepositoryTests.swift
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

// swiftlint:disable force_cast force_try
class ChallengeRepositoryTests: XCTestCase {

  private var challengeAPIClient: ChallengeAPIClientMock!
  private var challengeMapper: ChallengeMapperMock!
  private var challengeListMapper: ChallengeListMapperMock!
  private var challengeRepository: ChallengeRepository!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    challengeAPIClient = ChallengeAPIClientMock()
    challengeMapper = ChallengeMapperMock()
    challengeListMapper = ChallengeListMapperMock()
    challengeRepository = ChallengeRepository(apiClient: challengeAPIClient, challengeMapper: challengeMapper, challengeListMapper: challengeListMapper)
  }
  
  func testGetChallenge_withValidResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue]
    let expectedSignatureFieldsHeader = Constants.headers.values.first
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    let factor = generateFactor()
    let expectedFactorChallenge = generateFactorChallenge(withFactor: factor)
    challengeAPIClient.expectedChallengeSid = Constants.challengeSid
    challengeAPIClient.expectedFactor = factor
    challengeAPIClient.challengeData = challengeData
    challengeAPIClient.headers = Constants.headers
    challengeMapper.expectedData = challengeData
    challengeMapper.expectedSignatureFieldsHeader = expectedSignatureFieldsHeader
    
    challengeMapper.factorChallenge = expectedFactorChallenge
    var factorChallenge: FactorChallenge!
    challengeRepository.get(withSid: Constants.challengeSid, withFactor: factor, success: { challenge in
      factorChallenge = challenge as? FactorChallenge
      successExpectation.fulfill()
    }) { _ in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertEqual(factorChallenge.sid, expectedFactorChallenge.sid,
                   "FactorChallenge should be \(expectedFactorChallenge) but was \(factorChallenge!)")
    XCTAssertEqual(factorChallenge.factor?.sid, factor.sid,
                   "Factor should be \(factor) but was \(factorChallenge.factor!)")
  }

  func testGetChallenge_withInvalidResponse_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedError = NetworkError.invalidData
    challengeAPIClient.error = expectedError
    var error: Error!
    challengeRepository.get(withSid: Constants.challengeSid, withFactor: generateFactor(), success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { failure in
      error = failure
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual((error as! NetworkError).errorDescription, expectedError.errorDescription,
                   "Error should be \(expectedError) but was \(error!)")
  }

  func testGetChallenge_withErrorInMapper_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue]
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    challengeAPIClient.expectedChallengeSid = Constants.challengeSid
    let factor = generateFactor()
    challengeAPIClient.expectedFactor = factor
    challengeAPIClient.challengeData = challengeData
    challengeAPIClient.headers = Constants.headers
    let expectedError = MapperError.invalidArgument
    challengeMapper.error = expectedError
    var error: Error!
    challengeRepository.get(withSid: Constants.challengeSid, withFactor: factor, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { failure in
      error = failure
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual((error as! MapperError).errorDescription, expectedError.errorDescription,
                   "Error should be \(expectedError) but was \(error!)")
  }

  func testGetChallenge_withWrongFactorForChallenge_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue]
    let expectedSignatureFieldsHeader = Constants.headers.values.first
    let factor = generateFactor()
    let factor2 = generateFactor(withSid: "anotherSid")
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    challengeAPIClient.expectedChallengeSid = Constants.challengeSid
    challengeAPIClient.expectedFactor = factor2
    challengeAPIClient.challengeData = challengeData
    challengeAPIClient.headers = Constants.headers
    challengeMapper.expectedData = challengeData
    challengeMapper.expectedSignatureFieldsHeader = expectedSignatureFieldsHeader
    let expectedFactorChallenge = generateFactorChallenge(withFactor: factor)
    challengeMapper.factorChallenge = expectedFactorChallenge
    var error: Error!
    challengeRepository.get(withSid: Constants.challengeSid, withFactor: factor2, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { failure in
      error = failure
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual((error as! InputError).errorDescription, InputError.invalidInput(field: "wrong factor for challenge").errorDescription,
                   "Error should be \(InputError.invalidInput) but was \(error!)")
  }

  func testUpdateChallenge_withValidResponse_shouldSucced() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue]
    let expectedSignatureFieldsHeader = Constants.headers.values.first
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    let factor = generateFactor()
    let expectedFactorChallenge = generateFactorChallenge(withFactor: factor)
    challengeAPIClient.expectedChallenge = expectedFactorChallenge
    challengeAPIClient.expectedPayload = Constants.payload
    challengeAPIClient.expectedChallengeSid = expectedFactorChallenge.sid
    challengeAPIClient.expectedFactor = expectedFactorChallenge.factor
    challengeAPIClient.challengeData = challengeData
    challengeAPIClient.headers = Constants.headers
    challengeMapper.expectedData = challengeData
    challengeMapper.expectedSignatureFieldsHeader = expectedSignatureFieldsHeader
    challengeMapper.factorChallenge = expectedFactorChallenge
    var factorChallenge: FactorChallenge!
    challengeRepository.update(expectedFactorChallenge, payload: Constants.payload, success: { challenge in
      factorChallenge = challenge as? FactorChallenge
      successExpectation.fulfill()
    }) { _ in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertEqual(factorChallenge.sid, expectedFactorChallenge.sid,
                   "FactorChallenge should be \(expectedFactorChallenge) but was \(factorChallenge!)")
    XCTAssertEqual(factorChallenge.factor?.sid, factor.sid,
                   "Factor should be \(factor) but was \(factorChallenge.factor!)")
  }

  func testUpdateChallenge_withNoFactor_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedFactorChallenge = generateFactorChallenge(withFactor: nil)
    var error: Error!
    challengeRepository.update(expectedFactorChallenge, payload: Constants.payload, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { failure in
      error = failure
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual((error as! InputError).errorDescription, InputError.invalidInput(field: "invalid factor").errorDescription,
                   "Error should be \(InputError.invalidInput) but was \(error!)")
  }

  func testUpdateChallenge_withExpiredStatus_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let factorChallenge = generateFactorChallenge(withStatus: .expired, withFactor: generateFactor())
    var error: Error!
    challengeRepository.update(factorChallenge, payload: Constants.payload, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { failure in
      error = failure
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual((error as! InputError).errorDescription, InputError.invalidInput(field: "responded or expired challenge can not be updated").errorDescription,
                   "Error should be \(InputError.invalidInput) but was \(error!)")
  }
}

private extension ChallengeRepositoryTests {
  struct Constants {
    static let sidKey = "sid"
    static let factorSidKey = "factor_sid"
    static let createdDateKey = "date_created"
    static let updatedDateKey = "date_updated"
    static let statusKey = "status"
    static let expectedSidValue = "sid123"
    static let expectedFactorSid = "factorSid123"
    static let expectedCreatedDate = "2020-06-05T15:57:47Z"
    static let expectedUpdatedDate = "2020-07-08T15:57:47Z"
    static let challengeSid = "sid123"
    static let payload = "payload123"
    static let headers = [ChallengeRepository.Constants.signatureFieldsHeader: "value1, value2, value3"]
  }
  
  func generateFactor(withSid sid: String = Constants.expectedFactorSid) -> Factor {
    PushFactor(
      sid: sid,
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"))
  }
  
  func generateFactorChallenge(withStatus status: ChallengeStatus = .pending, withFactor factor: Factor?) -> FactorChallenge {
    FactorChallenge(
      sid: "challengeSid123",
      challengeDetails: ChallengeDetails(message: "message", fields: [], date: Date()),
      hiddenDetails: ["key": "value"],
      factorSid: factor?.sid ?? "12345",
      status: status,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: factor)
  }
}
