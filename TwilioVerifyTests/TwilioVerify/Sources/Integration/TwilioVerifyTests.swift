//
//  TwilioVerifyTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/23/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class TwilioVerifyTests: XCTestCase {

  private var twilioVerify: TwilioVerify!
  private var networkProvider: NetworkProviderMock!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    networkProvider = NetworkProviderMock()
    twilioVerify = try! TwilioVerifyBuilder().setURL("https://twilio.com").setNetworkProvider(networkProvider).build()
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
    XCTAssertEqual(challenge.sid, Constants.expectedResponse[Constants.sidKey],
                   "Sid should be \(Constants.expectedResponse[Constants.sidKey]!!) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, Constants.expectedResponse[Constants.factorSidKey],
                   "FactorSid should be \(Constants.expectedResponse[Constants.factorSidKey]!!) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(Constants.expectedResponse[Constants.createdDateKey]!!),
                   "CreatedAt should be \(DateFormatter().RFC3339(Constants.expectedResponse[Constants.createdDateKey]!!)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(Constants.expectedResponse[Constants.updatedDateKey]!!),
                   "UpdatedAt should be \(DateFormatter().RFC3339(Constants.expectedResponse[Constants.updatedDateKey]!!)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, Constants.expectedResponse[Constants.statusKey],
                   "Status should be \(Constants.expectedResponse[Constants.statusKey]!!) but was \(challenge.status.rawValue)")
    XCTAssertEqual(challenge.challengeDetails.message, Constants.details[Constants.messageKey] as! String,
                   "Detail message should be \(Constants.details[Constants.messageKey] as! String) but was \(challenge.challengeDetails.message)")
    XCTAssertEqual(challenge.challengeDetails.fields.count, (Constants.details[Constants.fieldsKey] as! [[String: String]]).count,
                   "Detail fields count should be \((Constants.details[Constants.fieldsKey] as! [[String: String]]).count) but was \(challenge.challengeDetails.fields.count)")
    XCTAssertEqual(challenge.challengeDetails.date, DateFormatter().RFC3339(Constants.details[Constants.dateKey]! as! String),
                   "Detail date should be \(DateFormatter().RFC3339(Constants.details[Constants.dateKey]! as! String)!) but was \(challenge.challengeDetails.date!)")
    XCTAssertEqual(challenge.hiddenDetails, Constants.hiddenDetailsString,
                   "Hidden details should be \(Constants.hiddenDetailsString!) but was \(challenge.hiddenDetails)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(Constants.expectedResponse[Constants.expirationDateKey]!!),
                   "Expiration date should be \(DateFormatter().RFC3339(Constants.expectedResponse[Constants.expirationDateKey]!!)!) but was \(challenge.expirationDate)")
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
    let expectedUpdateResponse = [Constants.sidKey: Constants.expectedSidValue,
                                  Constants.factorSidKey: Constants.expectedFactorSid,
                                  Constants.createdDateKey: Constants.expectedCreatedDate,
                                  Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                  Constants.statusKey: ChallengeStatus.approved.rawValue,
                                  Constants.detailsKey: Constants.detailsString,
                                  Constants.hiddenDetailsKey: Constants.hiddenDetailsString,
                                  Constants.expirationDateKey: Constants.expectedExpirationDate]
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
    let details: [String : Any] = [Constants.messageKey: Constants.expectedMessage,
                                   Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                         [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]],
                                   Constants.dateKey: Constants.expectedDateValue]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.utf8)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallenge1 = [Constants.sidKey: Constants.expectedSidValue,
                              Constants.factorSidKey: Constants.expectedFactorSid,
                              Constants.createdDateKey: Constants.expectedCreatedDate,
                              Constants.updatedDateKey: Constants.expectedUpdatedDate,
                              Constants.statusKey: Constants.expectedChallengeStatus.rawValue,
                              Constants.detailsKey: detailsString,
                              Constants.hiddenDetailsKey: hiddenDetailsString,
                              Constants.expirationDateKey: Constants.expectedExpirationDate]
    let expectedChallenge2 = [Constants.sidKey: Constants.expectedSidValue2,
                              Constants.factorSidKey: Constants.expectedFactorSid,
                              Constants.createdDateKey: Constants.expectedCreatedDate,
                              Constants.updatedDateKey: Constants.expectedUpdatedDate,
                              Constants.statusKey: Constants.expectedChallengeStatus.rawValue,
                              Constants.detailsKey: detailsString,
                              Constants.hiddenDetailsKey: hiddenDetailsString,
                              Constants.expirationDateKey: Constants.expectedExpirationDate]
    let challenges = [expectedChallenge1, expectedChallenge2]
    let metadata = [Constants.pageSizeKey: Constants.expectedPageSize,
                    Constants.pageKey: Constants.expectedPage,
                    Constants.nextPageKey: Constants.expectedNextPage,
                    Constants.previousPageKey: Constants.expectedPreviousPage] as [String : Any]
    let expectedResponse = [Constants.challengesKey: challenges,
                            Constants.metadataKey: metadata] as [String : Any]
    let data = try! JSONSerialization.data(withJSONObject: expectedResponse, options: .prettyPrinted)
    networkProvider.response = Response(data: data, headers: [:])
    var challengeList: ChallengeList!
    twilioVerify.getAllChallenges(withPayload: Constants.challengeListPayload, success: { response in
      challengeList = response
      expectation.fulfill()
    }) { error in
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
}

private extension TwilioVerifyTests {
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

private extension TwilioVerifyTests {
  struct Constants {
    static let sidKey = "sid"
    static let factorSidKey = "factor_sid"
    static let createdDateKey = "date_created"
    static let updatedDateKey = "date_updated"
    static let statusKey = "status"
    static let expectedChallengeStatus = ChallengeStatus.pending
    static let expectedChallengeStatus2 = ChallengeStatus.approved
    static let detailsKey = "details"
    static let hiddenDetailsKey = "hidden_details"
    static let expirationDateKey = "expiration_date"
    static let messageKey = "message"
    static let fieldsKey = "fields"
    static let labelKey = "label"
    static let valueKey = "value"
    static let dateKey = "date"
    static let challengesKey = "challenges"
    static let pageSizeKey = "page_size"
    static let metadataKey = "meta"
    static let pageKey = "page"
    static let previousPageKey = "previous_page_url"
    static let nextPageKey = "next_page_url"
    static let expectedSidValue = "sid123"
    static let expectedSidValue2 = "sid123"
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
    static let details: [String : Any] = [Constants.messageKey: Constants.expectedMessage,
                                          Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                                [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]],
                                          Constants.dateKey: Constants.expectedDateValue]
    static let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    static let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    static let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    static let expectedResponse = [Constants.sidKey: Constants.expectedSidValue,
                                   Constants.factorSidKey: Constants.expectedFactorSid,
                                   Constants.createdDateKey: Constants.expectedCreatedDate,
                                   Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                   Constants.statusKey: Constants.expectedChallengeStatus.rawValue,
                                   Constants.detailsKey: detailsString,
                                   Constants.hiddenDetailsKey: hiddenDetailsString,
                                   Constants.expirationDateKey: Constants.expectedExpirationDate]
    static let challengeListPayload = ChallengeListPayload(factorSid: expectedFactorSid, pageSize: 3)
  }
}
