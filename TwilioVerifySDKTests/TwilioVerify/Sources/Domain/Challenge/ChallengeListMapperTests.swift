//
//  ChallengeListMapperTests.swift
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
class ChallengeListMapperTests: XCTestCase {

  private var challengeMapper: ChallengeMapperMock!
  private var mapper: ChallengeListMapper!

  override func setUpWithError() throws {
    try super.setUpWithError()
    challengeMapper = ChallengeMapperMock()
    mapper = ChallengeListMapper(challengeMapper: challengeMapper)
  }
  
  func testFromAPI_withValidResponse_shouldReturnChallengeList() {
    challengeMapper.factorChallenge = Constants.challenge
    let challengeListData = try! JSONEncoder().encode(Constants.expectedChallengeListDTO)
    var challengeList: ChallengeList!
    XCTAssertNoThrow(challengeList = try mapper.fromAPI(withData: challengeListData),
                     "Mapping from API should not throw")
    XCTAssertEqual(challengeList.metadata.page, Constants.expectedPage,
                   "Page should be \(Constants.expectedPage) but was \(challengeList.metadata.page)")
    XCTAssertEqual(challengeList.metadata.pageSize, Constants.expectedPageSize,
                   "Page size should be \(Constants.expectedPageSize) but was \(challengeList.metadata.pageSize)")
    XCTAssertEqual(challengeList.metadata.nextPageToken, Constants.expectedNextPageToken,
                   "Next page token should be \(Constants.expectedNextPageToken) but was \(challengeList.metadata.nextPageToken!)")
    XCTAssertEqual(challengeList.metadata.previousPageToken, Constants.expectedPreviousPageToken,
                   "Previous page token should be \(Constants.expectedPreviousPageToken) but was \(challengeList.metadata.previousPageToken!)")
    XCTAssertEqual(challengeList.challenges.count, Constants.expectedChallenges.count,
                   "Challenges count should be \(Constants.expectedChallenges.count) but was \(challengeList.challenges.count)")
    XCTAssertEqual(Constants.expectedChallenges.count, challengeMapper.callsToMap,
                   "Calls to map should be \(Constants.expectedChallenges.count) but was \(challengeMapper.callsToMap)")
  }
  
  func testFromAPI_withValidResponseAndNoPreviousPageUrl_shouldReturnChallengeList() {
    let expectedChallengeListDTO = ChallengeListDTO(
      challenges: Constants.expectedChallenges,
      meta: MetadataDTO(page: Constants.expectedPage, pageSize: Constants.expectedPageSize, previousPageURL: nil, nextPageURL: Constants.expectedNextPageURL)
    )
    challengeMapper.factorChallenge = Constants.challenge
    let challengeListData = try! JSONEncoder().encode(expectedChallengeListDTO)
    var challengeList: ChallengeList!
    XCTAssertNoThrow(challengeList = try mapper.fromAPI(withData: challengeListData),
                     "Mapping from API should not throw")
    XCTAssertEqual(challengeList.metadata.page, Constants.expectedPage,
                   "Page should be \(Constants.expectedPage) but was \(challengeList.metadata.page)")
    XCTAssertEqual(challengeList.metadata.pageSize, Constants.expectedPageSize,
                   "Page size should be \(Constants.expectedPageSize) but was \(challengeList.metadata.pageSize)")
    XCTAssertEqual(challengeList.metadata.nextPageToken, Constants.expectedNextPageToken,
                   "Next page token should be \(Constants.expectedNextPageToken) but was \(challengeList.metadata.nextPageToken!)")
    XCTAssertNil(challengeList.metadata.previousPageToken,
                   "Previous page token should be nil but was \(challengeList.metadata.previousPageToken!)")
    XCTAssertEqual(challengeList.challenges.count, Constants.expectedChallenges.count,
                   "Challenges count should be \(Constants.expectedChallenges.count) but was \(challengeList.challenges.count)")
    XCTAssertEqual(Constants.expectedChallenges.count, challengeMapper.callsToMap,
                   "Calls to map should be \(Constants.expectedChallenges.count) but was \(challengeMapper.callsToMap)")
  }
  
  func testFromAPI_withValidResponseAndNoPreviousPageToken_shouldReturnChallengeList() {
    let expectedChallengeListDTO = ChallengeListDTO(
      challenges: Constants.expectedChallenges,
      meta: MetadataDTO(page: Constants.expectedPage, pageSize: Constants.expectedPageSize, previousPageURL: "http://www.twilio.com", nextPageURL: Constants.expectedNextPageURL)
    )
    challengeMapper.factorChallenge = Constants.challenge
    let challengeListData = try! JSONEncoder().encode(expectedChallengeListDTO)
    var challengeList: ChallengeList!
    XCTAssertNoThrow(challengeList = try mapper.fromAPI(withData: challengeListData),
                     "Mapping from API should not throw")
    XCTAssertEqual(challengeList.metadata.page, Constants.expectedPage,
                   "Page should be \(Constants.expectedPage) but was \(challengeList.metadata.page)")
    XCTAssertEqual(challengeList.metadata.pageSize, Constants.expectedPageSize,
                   "Page size should be \(Constants.expectedPageSize) but was \(challengeList.metadata.pageSize)")
    XCTAssertEqual(challengeList.metadata.nextPageToken, Constants.expectedNextPageToken,
                   "Next page token should be \(Constants.expectedNextPageToken) but was \(challengeList.metadata.nextPageToken!)")
    XCTAssertNil(challengeList.metadata.previousPageToken,
                   "Previous page token should be nil but was \(challengeList.metadata.previousPageToken!)")
    XCTAssertEqual(challengeList.challenges.count, Constants.expectedChallenges.count,
                   "Challenges count should be \(Constants.expectedChallenges.count) but was \(challengeList.challenges.count)")
    XCTAssertEqual(Constants.expectedChallenges.count, challengeMapper.callsToMap,
                   "Calls to map should be \(Constants.expectedChallenges.count) but was \(challengeMapper.callsToMap)")
  }
  
  func testFromAPI_withValidResponseAndNoNextPageUrl_shouldReturnChallengeList() {
    let expectedChallengeListDTO = ChallengeListDTO(
      challenges: Constants.expectedChallenges,
      meta: MetadataDTO(page: Constants.expectedPage, pageSize: Constants.expectedPageSize, previousPageURL: Constants.expectedPreviousPageURL, nextPageURL: nil)
    )
    challengeMapper.factorChallenge = Constants.challenge
    let challengeListData = try! JSONEncoder().encode(expectedChallengeListDTO)
    var challengeList: ChallengeList!
    XCTAssertNoThrow(challengeList = try mapper.fromAPI(withData: challengeListData),
                     "Mapping from API should not throw")
    XCTAssertEqual(challengeList.metadata.page, Constants.expectedPage,
                   "Page should be \(Constants.expectedPage) but was \(challengeList.metadata.page)")
    XCTAssertEqual(challengeList.metadata.pageSize, Constants.expectedPageSize,
                   "Page size should be \(Constants.expectedPageSize) but was \(challengeList.metadata.pageSize)")
    XCTAssertNil(challengeList.metadata.nextPageToken,
                 "Next page token should be nil but was \(challengeList.metadata.nextPageToken!)")
    XCTAssertEqual(challengeList.metadata.previousPageToken, Constants.expectedPreviousPageToken,
    "Previous page token should be \(Constants.expectedPreviousPageToken) but was \(challengeList.metadata.previousPageToken!)")
    XCTAssertEqual(challengeList.challenges.count, Constants.expectedChallenges.count,
                   "Challenges count should be \(Constants.expectedChallenges.count) but was \(challengeList.challenges.count)")
    XCTAssertEqual(Constants.expectedChallenges.count, challengeMapper.callsToMap,
                   "Calls to map should be \(Constants.expectedChallenges.count) but was \(challengeMapper.callsToMap)")
  }
  
  func testFromAPI_withValidResponseAndNoNextPageToken_shouldReturnChallengeList() {
    let expectedChallengeListDTO = ChallengeListDTO(
      challenges: Constants.expectedChallenges,
      meta: MetadataDTO(page: Constants.expectedPage, pageSize: Constants.expectedPageSize, previousPageURL: Constants.expectedPreviousPageURL, nextPageURL: "http://www.twilio.com")
    )
    challengeMapper.factorChallenge = Constants.challenge
    let challengeListData = try! JSONEncoder().encode(expectedChallengeListDTO)
    var challengeList: ChallengeList!
    XCTAssertNoThrow(challengeList = try mapper.fromAPI(withData: challengeListData),
                     "Mapping from API should not throw")
    XCTAssertEqual(challengeList.metadata.page, Constants.expectedPage,
                   "Page should be \(Constants.expectedPage) but was \(challengeList.metadata.page)")
    XCTAssertEqual(challengeList.metadata.pageSize, Constants.expectedPageSize,
                   "Page size should be \(Constants.expectedPageSize) but was \(challengeList.metadata.pageSize)")
    XCTAssertNil(challengeList.metadata.nextPageToken,
                 "Next page token should be nil but was \(challengeList.metadata.nextPageToken!)")
    XCTAssertEqual(challengeList.metadata.previousPageToken, Constants.expectedPreviousPageToken,
    "Previous page token should be \(Constants.expectedPreviousPageToken) but was \(challengeList.metadata.previousPageToken!)")
    XCTAssertEqual(challengeList.challenges.count, Constants.expectedChallenges.count,
                   "Challenges count should be \(Constants.expectedChallenges.count) but was \(challengeList.challenges.count)")
    XCTAssertEqual(Constants.expectedChallenges.count, challengeMapper.callsToMap,
                   "Calls to map should be \(Constants.expectedChallenges.count) but was \(challengeMapper.callsToMap)")
  }
  
  func testFromAPI_withValidResponseAndInvalidNextPageUrl_shouldReturnChallengeList() {
    let expectedChallengeListDTO = ChallengeListDTO(
      challenges: Constants.expectedChallenges,
      meta: MetadataDTO(page: Constants.expectedPage, pageSize: Constants.expectedPageSize, previousPageURL: Constants.expectedPreviousPageURL, nextPageURL: "twilio")
    )
    challengeMapper.factorChallenge = Constants.challenge
    let challengeListData = try! JSONEncoder().encode(expectedChallengeListDTO)
    var challengeList: ChallengeList!
    XCTAssertNoThrow(challengeList = try mapper.fromAPI(withData: challengeListData),
                     "Mapping from API should not throw")
    XCTAssertEqual(challengeList.metadata.page, Constants.expectedPage,
                   "Page should be \(Constants.expectedPage) but was \(challengeList.metadata.page)")
    XCTAssertEqual(challengeList.metadata.pageSize, Constants.expectedPageSize,
                   "Page size should be \(Constants.expectedPageSize) but was \(challengeList.metadata.pageSize)")
    XCTAssertNil(challengeList.metadata.nextPageToken,
                 "Next page token should be nil but was \(challengeList.metadata.nextPageToken!)")
    XCTAssertEqual(challengeList.metadata.previousPageToken, Constants.expectedPreviousPageToken,
    "Previous page token should be \(Constants.expectedPreviousPageToken) but was \(challengeList.metadata.previousPageToken!)")
    XCTAssertEqual(challengeList.challenges.count, Constants.expectedChallenges.count,
                   "Challenges count should be \(Constants.expectedChallenges.count) but was \(challengeList.challenges.count)")
    XCTAssertEqual(Constants.expectedChallenges.count, challengeMapper.callsToMap,
                   "Calls to map should be \(Constants.expectedChallenges.count) but was \(challengeMapper.callsToMap)")
  }
  
  func testFromAPI_withNoPage_shouldThrow() {
    let challengeListDTO = [Constants.challengesKey: [ChallengeDTO](),
                            Constants.metadataKey: []]
    let challengeListData = try! JSONEncoder().encode(challengeListDTO)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeListData), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.errorDescription, TwilioVerifyError.mapperError(error: TestError.operationFailed).errorDescription,
                   "Error should be \(TwilioVerifyError.mapperError(error: TestError.operationFailed).errorDescription!) but was \(error.errorDescription!)")
  }
  
  func testFromAPI_withErrorMappingChallengeDTO_shouldThrow() {
    challengeMapper.error = MapperError.illegalArgument
    let challengesData = try! JSONEncoder().encode(Constants.expectedChallengeListDTO)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengesData), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.originalError as! MapperError, MapperError.illegalArgument,
                   "Error should be \(MapperError.illegalArgument) but was \(error.originalError)")
  }
}

private extension ChallengeListMapperTests {
  struct Constants {
    static let messageKey = "message"
    static let fieldsKey = "fields"
    static let labelKey = "label"
    static let valueKey = "value"
    static let dateKey = "date"
    static let pageSizeKey = "pageSize"
    static let nextPageURLKey = "nextPageURL"
    static let keyKey = "key"
    static let challengesKey = "challenges"
    static let metadataKey = "meta"
    static let expectedSidValue1 = "sid123"
    static let expectedSidValue2 = "sid123"
    static let expectedFactorSid = "factorSid123"
    static let expectedCreatedDate = "2020-06-05T15:57:47Z"
    static let expectedUpdatedDate = "2020-07-08T15:57:47Z"
    static let expectedMessage = "message123"
    static let expectedLabel1 = "Label1"
    static let expectedLabel2 = "Label2"
    static let expectedValue1 = "Value1"
    static let expectedValue2 = "Value2"
    static let expectedDateValue = "2020-02-19T16:39:57-08:00"
    static let expectedExpirationDate = "2020-09-10T15:57:47Z"
    static let expectedPage = 1
    static let expectedPageSize = 20
    static let expectedPreviousPageToken = "previousPageToken"
    static let expectedPreviousPageURL = "http://www.twilio.com?\(ChallengeListMapper.Constants.pageToken)=\(expectedPreviousPageToken)"
    static let expectedNextPageToken = "nextPageToken"
    static let expectedNextPageURL = "http://www.twilio.com?\(ChallengeListMapper.Constants.pageToken)=\(expectedNextPageToken)"
    static let expectedKey = "key"
    static let challengeSid = "sid123"
    static let details = ChallengeDetailsDTO(message: "message", fields: [], date: nil)
    static let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    static let expectedMetadata = MetadataDTO(page: expectedPage, pageSize: expectedPageSize, previousPageURL: expectedPreviousPageURL, nextPageURL: expectedNextPageURL)
    static let expectedChallenges = [generateChallengeDTO(withSid: expectedSidValue1, withStatus: .approved),
                                     generateChallengeDTO(withSid: expectedSidValue2, withStatus: .denied)]
    static let challenge = generateFactorChallenge(withStatus: .approved, withFactor: generateFactor(withSid: Constants.expectedFactorSid))
    static let expectedChallengeListDTO = ChallengeListDTO(challenges: Constants.expectedChallenges, meta: Constants.expectedMetadata)
  }
  
  static func generateChallengeDTO(withSid sid: String, withStatus status: ChallengeStatus) -> ChallengeDTO {
    ChallengeDTO(
      sid: sid,
      details: Constants.details,
      hiddenDetails: Constants.hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: status,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
  }
  
  static func generateFactor(withSid sid: String = Constants.expectedFactorSid) -> Factor {
    PushFactor(
      sid: sid,
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      identity: "identity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"))
  }
  
  static func generateFactorChallenge(withStatus status: ChallengeStatus = .pending, withFactor factor: Factor?) -> FactorChallenge {
    FactorChallenge(
      sid: Constants.expectedSidValue1,
      challengeDetails: ChallengeDetails(message: Constants.expectedMessage, fields: [], date: Date()),
      hiddenDetails: ["key": "value"],
      factorSid: factor?.sid ?? "12345",
      status: status,
      createdAt: Date(),
      updatedAt: Date(),
      expirationDate: Date(),
      factor: factor)
  }
}
