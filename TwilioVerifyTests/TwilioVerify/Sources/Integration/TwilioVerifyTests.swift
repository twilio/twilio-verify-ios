//
//  TwilioVerifyTests.swift
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
@testable import TwilioVerify

// swiftlint:disable force_cast force_try
class TwilioVerifyTests: XCTestCase {

  private var twilioVerify: TwilioVerifySDK!
  private var networkProvider: NetworkProviderMock!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    networkProvider = NetworkProviderMock()
    twilioVerify = try! TwilioVerifyBuilder()
                        .setURL("https://twilio.com")
                        .setNetworkProvider(networkProvider)
                        .setClearStorageOnReinstall(true)
                        .enableDefaultLoggingService(withLevel: .all)
                        .build()
  }
  
  func testCreateFactor_shouldSucceed() {
    createFactor()
  }
  
  func testVerifyFactor_shouldSucceed() {
    createFactor()
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse: [String: Any] = [Constants.sidKey: Constants.expectedFactorSid,
                                           Constants.statusKey: FactorStatus.verified.rawValue]
    let data = try! JSONSerialization.data(withJSONObject: expectedResponse, options: .prettyPrinted)
    networkProvider.response = Response(data: data, headers: [:])
    let factorPayload = VerifyPushFactorPayload(sid: Constants.expectedFactorSid)
    var pushFactor: PushFactor!
    twilioVerify.verifyFactor(withPayload: factorPayload, success: { factor in
      pushFactor = factor as? PushFactor
      successExpectation.fulfill()
    }) { _ in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertEqual(pushFactor.sid, expectedResponse[Constants.sidKey] as! String,
                   "Sid should be \(expectedResponse[Constants.sidKey] as! String) but was \(pushFactor.sid)")
    XCTAssertEqual(pushFactor.status, FactorStatus(rawValue: expectedResponse[Constants.statusKey] as! String),
                   "Factor status should be \(FactorStatus(rawValue: expectedResponse[Constants.statusKey] as! String)!) but was \(pushFactor.status)")
  }
  
  func testUpdateFactor_shouldSucceed() {
    createFactor()
    let expectation = self.expectation(description: "testUpdateFactor_shouldSucceed")
    let expectedResponse: [String: Any] = [Constants.sidKey: Constants.expectedFactorSid,
                                           Constants.friendlyNameKey: Constants.friendlyNameValue,
                                           Constants.accountSidKey: Constants.accountSidValue,
                                           Constants.statusKey: Constants.statusValue,
                                           Constants.configKey: [Constants.credentialSidKey: Constants.credentialSidValue],
                                           Constants.dateCreatedKey: Constants.dateCreatedValue]
    let data = try! JSONSerialization.data(withJSONObject: expectedResponse, options: .prettyPrinted)
    networkProvider.response = Response(data: data, headers: [:])
    let payload = UpdatePushFactorPayload(sid: Constants.expectedFactorSid, pushToken: Constants.pushToken)
    var pushFactor: PushFactor!
    twilioVerify.updateFactor(withPayload: payload, success: { factor in
      pushFactor = factor as? PushFactor
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(pushFactor.sid, expectedResponse[Constants.sidKey] as! String,
                   "Factor sid should be \(expectedResponse[Constants.sidKey] as! String) but was \(pushFactor.sid)")
  }
  
  func testGetChallenge_shouldSucceed() {
    createFactor()
    let expectation = self.expectation(description: "testGetChallenge_shouldSucceed")
    let data = try! JSONSerialization.data(withJSONObject: Constants.expectedResponse, options: .prettyPrinted)
    networkProvider.response = Response(data: data, headers: [:])
    var challenge: FactorChallenge!
    twilioVerify.getChallenge(challengeSid: Constants.expectedSidValue, factorSid: Constants.expectedFactorSid, success: { response in
      challenge = response as? FactorChallenge
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(challenge.sid, Constants.expectedSidValue,
                   "Sid should be \(Constants.expectedSidValue) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, Constants.expectedFactorSid,
                   "FactorSid should be \(Constants.expectedFactorSid) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(Constants.expectedCreatedDate),
                   "CreatedAt should be \(DateFormatter().RFC3339(Constants.expectedCreatedDate)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(Constants.expectedUpdatedDate),
                   "UpdatedAt should be \(DateFormatter().RFC3339(Constants.expectedUpdatedDate)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, Constants.expectedChallengeStatus.rawValue,
                   "Status should be \(Constants.expectedChallengeStatus.rawValue) but was \(challenge.status.rawValue)")
    XCTAssertEqual(challenge.challengeDetails.message, Constants.expectedMessage,
                   "Detail message should be \(Constants.expectedMessage) but was \(challenge.challengeDetails.message)")
    XCTAssertEqual(challenge.challengeDetails.fields.count, Constants.fields.count,
                   "Detail fields count should be \(Constants.fields.count) but was \(challenge.challengeDetails.fields.count)")
    XCTAssertEqual(challenge.challengeDetails.date, DateFormatter().RFC3339(Constants.expectedDateValue),
                   "Detail date should be \(DateFormatter().RFC3339(Constants.expectedDateValue)!) but was \(challenge.challengeDetails.date!)")
    XCTAssertEqual(challenge.hiddenDetails, Constants.hiddenDetails,
                   "Hidden details should be \(Constants.hiddenDetails) but was \(challenge.hiddenDetails!)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(Constants.expectedExpirationDate),
                   "Expiration date should be \(DateFormatter().RFC3339(Constants.expectedExpirationDate)!) but was \(challenge.expirationDate)")
  }
  
  func testDeleteFactor_shouldSucceed() {
    createFactor()
    let expectation = self.expectation(description: "testDeleteFactor_shouldSucceed")
    twilioVerify.deleteFactor(withSid: Constants.expectedFactorSid, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testDeleteFactor_withoutExistingFactor_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withoutExistingFactor_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.deleteFactor(withSid: "anotherSid", success: {
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
  
  func testUpdateChallenge_shouldSucceed() {
    createFactor()
    let expectation = self.expectation(description: "testGetChallenge_shouldSucceed")
    var expectedUpdateResponse = Constants.expectedResponse
    expectedUpdateResponse[ChallengeDTO.CodingKeys.status.rawValue] = ChallengeStatus.approved.rawValue
    let dataGetChallenge = try! JSONSerialization.data(withJSONObject: Constants.expectedResponse, options: .prettyPrinted)
    let dataUpdateChallenge = try! JSONSerialization.data(withJSONObject: expectedUpdateResponse, options: .prettyPrinted)
    networkProvider.response = nil
    networkProvider.responses = [Response(data: dataGetChallenge, headers: [ChallengeRepository.Constants.signatureFieldsHeader: Constants.statusKey]),
                                 Response(data: Data(), headers: [:]),
                                 Response(data: dataUpdateChallenge, headers: [:])]
    twilioVerify.updateChallenge(withPayload: Constants.updatePushChallengePayload, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testGetAllFactors_shouldSucceed() {
    createFactor()
    let expectation = self.expectation(description: "testGetAllFactors_shouldSucceed")
    var factors: [Factor]!
    twilioVerify.getAllFactors(success: { response in
      factors = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertNotNil(factors.first(where: { $0.sid == Constants.expectedFactorSid }), "Factor should exists")
  }
  
  func testGetAllChallenges_shouldSucceed() {
    createFactor()
    let expectation = self.expectation(description: "testGetAllChallenges_shouldSucceed")
    let expectedChallenge1 = Constants.expectedResponse
    var expectedChallenge2 = Constants.expectedResponse
    expectedChallenge2[ChallengeDTO.CodingKeys.sid.rawValue] = Constants.expectedSidValue2
    expectedChallenge2[ChallengeDTO.CodingKeys.status.rawValue] = Constants.expectedChallengeStatus2.rawValue
    let challenges = [expectedChallenge1, expectedChallenge2]
    let metadata = [Constants.pageSizeKey: Constants.expectedPageSize,
                    Constants.pageKey: Constants.expectedPage,
                    Constants.nextPageKey: Constants.expectedNextPage,
                    Constants.previousPageKey: Constants.expectedPreviousPage] as [String: Any]
    let expectedResponse = [Constants.challengesKey: challenges,
                            Constants.metadataKey: metadata] as [String: Any]
    let data = try! JSONSerialization.data(withJSONObject: expectedResponse, options: .prettyPrinted)
    networkProvider.response = Response(data: data, headers: [:])
    var challengeList: ChallengeList!
    twilioVerify.getAllChallenges(withPayload: Constants.challengeListPayload, success: { response in
      challengeList = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 30, handler: nil)
    XCTAssertEqual(challengeList.challenges.count, challenges.count,
                   "Challenge list should have \(challenges.count) challenges but has \(challengeList.challenges.count) challenges")
    XCTAssertEqual(challengeList.metadata.page, Constants.expectedPage,
                   "Page should be \(Constants.expectedPage) but was \(challengeList.metadata.page)")
    XCTAssertEqual(challengeList.metadata.pageSize, Constants.expectedPageSize,
                   "Page size should be \(Constants.expectedPageSize) but was \(challengeList.metadata.pageSize)")
    XCTAssertEqual(challengeList.metadata.previousPageToken, Constants.expectedPreviousPageToken,
                   "Page size should be \(Constants.expectedPreviousPageToken) but was \(challengeList.metadata.previousPageToken!)")
    XCTAssertEqual(challengeList.metadata.nextPageToken, Constants.expectedNextPageToken,
                   "Page size should be \(Constants.expectedNextPageToken) but was \(challengeList.metadata.nextPageToken!)")
  }
  
  func testClearLocalStorage_shouldDeleteFactors() {
    createFactor()
    let expectation = self.expectation(description: "testClearLocalStorage_shouldDeleteFactors")
    XCTAssertNoThrow(try twilioVerify.clearLocalStorage(), "Clear local storage should not throw")
    var factors: [Factor]!
    
    twilioVerify.getAllFactors(success: { result in
      factors = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssert(factors.isEmpty, "Factors should be empty")
  }
}

private extension TwilioVerifyTests {
  struct Constants {
    static let sidKey = "sid"
    static let statusKey = "status"
    static let expectedChallengeStatus = ChallengeStatus.pending
    static let expectedChallengeStatus2 = ChallengeStatus.approved
    static let challengesKey = "challenges"
    static let pageSizeKey = "page_size"
    static let metadataKey = "meta"
    static let pageKey = "page"
    static let previousPageKey = "previous_page_url"
    static let nextPageKey = "next_page_url"
    static let expectedSidValue = "sid123"
    static let expectedSidValue2 = "sid345"
    static let expectedFactorSid = "factorSid123"
    static let expectedCreatedDate = "2020-06-05T15:57:47Z"
    static let expectedUpdatedDate = "2020-07-08T15:57:47Z"
    static let expectedExpirationDate = "2020-09-10T15:57:47Z"
    static let expectedMessage = "message123"
    static let expectedDateValue = "2020-02-19T16:39:57-08:00"
    static let expectedLabel1 = "Label1"
    static let expectedLabel2 = "Label2"
    static let expectedValue1 = "Value1"
    static let expectedValue2 = "Value2"
    static let expectedKey1 = "key1"
    static let expectedPageSize = 2
    static let expectedPage = 0
    static let expectedPreviousPageToken = "DNYC032ef13048d311b1d31a7cc4b16065e1"
    static let expectedNextPageToken = "DNYC033ef13049d311c1d31a8cc4b16065e1"
    static let expectedNextPage = "https://verify.twilio.com/Challenges?Page=1&PageToken=\(expectedNextPageToken)&PageSize=2"
    static let expectedPreviousPage = "https://verify.twilio.com/Challenges?Page=1&PageToken=\(expectedPreviousPageToken)&PageSize=2"
    static let challengeSid = "sid123"
    static let friendlyNameKey = "friendly_name"
    static let friendlyNameValue = "friendlyName"
    static let accountSidKey = "account_sid"
    static let accountSidValue = "accountSid123"
    static let statusValue = FactorStatus.unverified.rawValue
    static let configKey = "config"
    static let credentialSidKey = "credential_sid"
    static let credentialSidValue = "credentialSid123"
    static let dateCreatedKey = "date_created"
    static let dateCreatedValue = "2020-06-05T15:57:47Z"
    static let friendlyName = "friendlyName123"
    static let serviceSid = "serviceSid123"
    static let identity = "identityValue"
    static let pushToken = "ACBtoken"
    static let accessToken = "accessToken"
    static let expectedFactor = PushFactor(
      sid: "sid",
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"))
    static let updatePushChallengePayload = UpdatePushChallengePayload(
      factorSid: expectedFactorSid,
      challengeSid: expectedSidValue,
      status: .approved)
    static let fields = [Detail(label: Constants.expectedLabel1, value: Constants.expectedValue1),
                  Detail(label: Constants.expectedLabel2, value: Constants.expectedValue1)]
    static let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: fields,
      date: Constants.expectedDateValue)
    static let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    static let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedChallengeStatus,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
    static let challengeData = try! JSONEncoder().encode(challengeDTO)
    static let expectedResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    static let challengeListPayload = ChallengeListPayload(factorSid: expectedFactorSid, pageSize: 3)
  }
  
  func createFactor() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse: [String: Any] = [Constants.sidKey: Constants.expectedFactorSid,
                                           Constants.friendlyNameKey: Constants.friendlyNameValue,
                                           Constants.accountSidKey: Constants.accountSidValue,
                                           Constants.statusKey: Constants.statusValue,
                                           Constants.configKey: [Constants.credentialSidKey: Constants.credentialSidValue],
                                           Constants.dateCreatedKey: Constants.dateCreatedValue]
    let data = try! JSONSerialization.data(withJSONObject: expectedResponse, options: .prettyPrinted)
    networkProvider.response = Response(data: data, headers: [:])
    let accessToken = """
              eyJjdHkiOiJ0d2lsaW8tZnBhO3Y9MSIsInR5cCI6IkpXVCIsImFsZyI6IkhTMjU2In0.eyJpc3MiOiJTSz
              AwMTBjZDc5Yzk4NzM1ZTBjZDliYjQ5NjBlZjYyZmI4IiwiZXhwIjoxNTgzOTM3NjY0LCJncmFudHMiOnsidmVyaW
              Z5Ijp7ImlkZW50aXR5IjoiWUViZDE1NjUzZDExNDg5YjI3YzFiNjI1NTIzMDMwMTgxNSIsImZhY3RvciI6InB1c2
              giLCJyZXF1aXJlLWJpb21ldHJpY3MiOnRydWV9LCJhcGkiOnsiYXV0aHlfdjEiOlt7ImFjdCI6WyJjcmVhdGUiXS
              wicmVzIjoiL1NlcnZpY2VzL0lTYjNhNjRhZTBkMjI2MmEyYmFkNWU5ODcwYzQ0OGI4M2EvRW50aXRpZXMvWUViZD
              E1NjUzZDExNDg5YjI3YzFiNjI1NTIzMDMwMTgxNS9GYWN0b3JzIn1dfX0sImp0aSI6IlNLMDAxMGNkNzljOTg3Mz
              VlMGNkOWJiNDk2MGVmNjJmYjgtMTU4Mzg1MTI2NCIsInN1YiI6IkFDYzg1NjNkYWY4OGVkMjZmMjI3NjM4ZjU3Mz
              g3MjZmYmQifQ.R01YC9mfCzIf9W81GUUCMjTwnhzIIqxV-tcdJYuy6kA
              """
    let factorPayload = PushFactorPayload(
      friendlyName: Constants.friendlyName,
      serviceSid: Constants.serviceSid,
      identity: Constants.identity,
      pushToken: Constants.pushToken,
      accessToken: accessToken)
    var pushFactor: PushFactor!
    twilioVerify.createFactor(withPayload: factorPayload, success: { factor in
      pushFactor = factor as? PushFactor
      successExpectation.fulfill()
    }) { _ in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertEqual(pushFactor.sid, expectedResponse[Constants.sidKey] as! String,
                   "Sid should be \(expectedResponse[Constants.sidKey] as! String) but was \(pushFactor.sid)")
    XCTAssertNotNil(pushFactor.keyPairAlias, "Alias shouldn't be nil")
  }
}
