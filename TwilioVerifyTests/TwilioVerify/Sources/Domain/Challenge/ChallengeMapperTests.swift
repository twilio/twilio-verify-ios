//
//  ChallengeMapperTests.swift
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

// swiftlint:disable force_cast force_try type_body_length file_length function_body_length
class ChallengeMapperTests: XCTestCase {
  
  private var mapper: ChallengeMapper!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    mapper = ChallengeMapper()
  }
  
  func testFromAPI_withValidResponse_shouldReturnChallenge() {
    let fields = [Detail(label: Constants.expectedLabel1, value: Constants.expectedValue1),
                  Detail(label: Constants.expectedLabel2, value: Constants.expectedValue1)]
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: fields,
      date: Constants.expectedDateValue)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedStatus,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
    let challengeData = try! JSONEncoder().encode(challengeDTO)
    let expectedChallengeResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    var challenge: FactorChallenge!
    XCTAssertNoThrow(challenge = try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader),
                     "Mapping from API should not throw")
    XCTAssertEqual(challenge.sid, Constants.expectedSidValue,
                   "Sid should be \(Constants.expectedSidValue) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, Constants.expectedFactorSid,
                   "FactorSid should be \(Constants.expectedFactorSid) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(Constants.expectedCreatedDate),
                   "CreatedAt should be \(DateFormatter().RFC3339(Constants.expectedCreatedDate)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(Constants.expectedUpdatedDate),
                   "UpdatedAt should be \(DateFormatter().RFC3339(Constants.expectedUpdatedDate)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, Constants.expectedStatus.rawValue,
                   "Status should be \(Constants.expectedStatus.rawValue) but was \(challenge.status.rawValue)")
    XCTAssertEqual(challenge.response?.keys.count, expectedChallengeResponse.keys.count,
                   "Response should be \(expectedChallengeResponse) but was \(challenge.response!)")
    XCTAssertEqual(challenge.challengeDetails.message, Constants.expectedMessage,
                   "Detail message should be \(Constants.expectedMessage) but was \(challenge.challengeDetails.message)")
    XCTAssertEqual(challenge.challengeDetails.fields.count, fields.count,
                   "Detail fields count should be \(fields.count) but was \(challenge.challengeDetails.fields.count)")
    XCTAssertEqual(challenge.challengeDetails.date, DateFormatter().RFC3339(Constants.expectedDateValue),
                   "Detail date should be \(DateFormatter().RFC3339(Constants.expectedDateValue)!) but was \(challenge.challengeDetails.date!)")
    XCTAssertEqual(challenge.hiddenDetails, hiddenDetails,
                   "Hidden details should be \(hiddenDetails ) but was \(challenge.hiddenDetails!)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(Constants.expectedExpirationDate),
                   "Expiration date should be \(DateFormatter().RFC3339(Constants.expectedExpirationDate)!) but was \(challenge.expirationDate)")
    XCTAssertEqual(challenge.signatureFields?.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator), expectedSignatureFieldsHeader,
                   "Signature fields should be \(expectedSignatureFieldsHeader) but was \(challenge.signatureFields!.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator))")
  }
  
  func testFromAPI_withValidResponseWithoutFields_shouldReturnChallenge() {
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: [],
      date: Constants.expectedDateValue)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedStatus,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
    let challengeData = try! JSONEncoder().encode(challengeDTO)
    let expectedChallengeResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    var challenge: FactorChallenge!
    XCTAssertNoThrow(challenge = try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader),
                     "Mapping from API should not throw")
    XCTAssertEqual(challenge.sid, Constants.expectedSidValue,
                   "Sid should be \(Constants.expectedSidValue) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, Constants.expectedFactorSid,
                   "FactorSid should be \(Constants.expectedFactorSid) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(Constants.expectedCreatedDate),
                   "CreatedAt should be \(DateFormatter().RFC3339(Constants.expectedCreatedDate)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(Constants.expectedUpdatedDate),
                   "UpdatedAt should be \(DateFormatter().RFC3339(Constants.expectedUpdatedDate)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, Constants.expectedStatus.rawValue,
                   "Status should be \(Constants.expectedStatus.rawValue) but was \(challenge.status.rawValue)")
    XCTAssertEqual(challenge.response?.keys.count, expectedChallengeResponse.keys.count,
                   "Response should be \(expectedChallengeResponse) but was \(challenge.response!)")
    XCTAssertEqual(challenge.challengeDetails.message, Constants.expectedMessage,
                   "Detail message should be \(Constants.expectedMessage) but was \(challenge.challengeDetails.message)")
    XCTAssertTrue(challenge.challengeDetails.fields.isEmpty, "Detail fields should be empty")
    XCTAssertEqual(challenge.challengeDetails.date, DateFormatter().RFC3339(Constants.expectedDateValue),
                   "Detail date should be \(DateFormatter().RFC3339(Constants.expectedDateValue)!) but was \(challenge.challengeDetails.date!)")
    XCTAssertEqual(challenge.hiddenDetails, hiddenDetails,
                   "Hidden details should be \(hiddenDetails) but was \(challenge.hiddenDetails!)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(Constants.expectedExpirationDate),
                   "Expiration date should be \(DateFormatter().RFC3339(Constants.expectedExpirationDate)!) but was \(challenge.expirationDate)")
    XCTAssertEqual(challenge.signatureFields?.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator), expectedSignatureFieldsHeader,
                   "Signature fields should be \(expectedSignatureFieldsHeader) but was \(challenge.signatureFields!.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator))")
  }
  
  func testFromAPI_withValidResponseWithoutDetailsDate_shouldReturnChallenge() {
    let fields = [Detail(label: Constants.expectedLabel1, value: Constants.expectedValue1),
                  Detail(label: Constants.expectedLabel2, value: Constants.expectedValue1)]
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: fields,
      date: nil)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedStatus,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
    let challengeData = try! JSONEncoder().encode(challengeDTO)
    let expectedChallengeResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    var challenge: FactorChallenge!
    XCTAssertNoThrow(challenge = try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader),
                     "Mapping from API should not throw")
    XCTAssertEqual(challenge.sid, Constants.expectedSidValue,
                   "Sid should be \(Constants.expectedSidValue) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, Constants.expectedFactorSid,
                   "FactorSid should be \(Constants.expectedFactorSid) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(Constants.expectedCreatedDate),
                   "CreatedAt should be \(DateFormatter().RFC3339(Constants.expectedCreatedDate)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(Constants.expectedUpdatedDate),
                   "UpdatedAt should be \(DateFormatter().RFC3339(Constants.expectedUpdatedDate)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, Constants.expectedStatus.rawValue,
                   "Status should be \(Constants.expectedStatus.rawValue) but was \(challenge.status.rawValue)")
    XCTAssertEqual(challenge.response?.keys.count, expectedChallengeResponse.keys.count,
                   "Response should be \(expectedChallengeResponse) but was \(challenge.response!)")
    XCTAssertEqual(challenge.challengeDetails.message, Constants.expectedMessage,
                   "Detail message should be \(Constants.expectedMessage) but was \(challenge.challengeDetails.message)")
    XCTAssertEqual(challenge.challengeDetails.fields.count, fields.count,
                   "Detail fields count should be \(fields.count) but was \(challenge.challengeDetails.fields.count)")
    XCTAssertNil(challenge.challengeDetails.date, "Details date should be nil")
    XCTAssertEqual(challenge.hiddenDetails, hiddenDetails,
                   "Hidden details should be \(hiddenDetails) but was \(challenge.hiddenDetails!)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(Constants.expectedExpirationDate),
                   "Expiration date should be \(DateFormatter().RFC3339(Constants.expectedExpirationDate)!) but was \(challenge.expirationDate)")
    XCTAssertEqual(challenge.signatureFields?.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator), expectedSignatureFieldsHeader,
                   "Signature fields should be \(expectedSignatureFieldsHeader) but was \(challenge.signatureFields!.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator))")
  }
  
  func testFromAPI_withValidResponseAndApprovedStatus_shouldReturnChallenge() {
    let fields = [Detail(label: Constants.expectedLabel1, value: Constants.expectedValue1),
                  Detail(label: Constants.expectedLabel2, value: Constants.expectedValue1)]
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: fields,
      date: Constants.expectedDateValue)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: ChallengeStatus.approved,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
    let challengeData = try! JSONEncoder().encode(challengeDTO)
    let expectedChallengeResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    var challenge: FactorChallenge!
    XCTAssertNoThrow(challenge = try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader),
                     "Mapping from API should not throw")
    XCTAssertEqual(challenge.sid, Constants.expectedSidValue,
                   "Sid should be \(Constants.expectedSidValue) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, Constants.expectedFactorSid,
                   "FactorSid should be \(Constants.expectedFactorSid) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(Constants.expectedCreatedDate),
                   "CreatedAt should be \(DateFormatter().RFC3339(Constants.expectedCreatedDate)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(Constants.expectedUpdatedDate),
                   "UpdatedAt should be \(DateFormatter().RFC3339(Constants.expectedUpdatedDate)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, ChallengeStatus.approved.rawValue,
                   "Status should be \(ChallengeStatus.approved.rawValue) but was \(challenge.status.rawValue)")
    XCTAssertNil(challenge.response, "Response should be nil")
    XCTAssertEqual(challenge.challengeDetails.message, Constants.expectedMessage,
                   "Detail message should be \(Constants.expectedMessage) but was \(challenge.challengeDetails.message)")
    XCTAssertEqual(challenge.challengeDetails.fields.count, fields.count,
                   "Detail fields count should be \(fields.count) but was \(challenge.challengeDetails.fields.count)")
    XCTAssertEqual(challenge.challengeDetails.date, DateFormatter().RFC3339(Constants.expectedDateValue),
                   "Detail date should be \(DateFormatter().RFC3339(Constants.expectedDateValue)!) but was \(challenge.challengeDetails.date!)")
    XCTAssertEqual(challenge.hiddenDetails, hiddenDetails,
                   "Hidden details should be \(hiddenDetails) but was \(challenge.hiddenDetails!)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(Constants.expectedExpirationDate),
                   "Expiration date should be \(DateFormatter().RFC3339(Constants.expectedExpirationDate)!) but was \(challenge.expirationDate)")
    XCTAssertNil(challenge.signatureFields, "Signature fields should be nil")
  }
  
  func testFromAPI_withValidResponseWithPendingStatusAndNoSignatureFields_shouldReturnChallenge() {
    let fields = [Detail(label: Constants.expectedLabel1, value: Constants.expectedValue1),
                  Detail(label: Constants.expectedLabel2, value: Constants.expectedValue1)]
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: fields,
      date: Constants.expectedDateValue)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedStatus,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
    let challengeData = try! JSONEncoder().encode(challengeDTO)
    var challenge: FactorChallenge!
    XCTAssertNoThrow(challenge = try mapper.fromAPI(withData: challengeData), "Mapping from API should not throw")
    XCTAssertEqual(challenge.sid, Constants.expectedSidValue,
                   "Sid should be \(Constants.expectedSidValue) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, Constants.expectedFactorSid,
                   "FactorSid should be \(Constants.expectedFactorSid) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(Constants.expectedCreatedDate),
                   "CreatedAt should be \(DateFormatter().RFC3339(Constants.expectedCreatedDate)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(Constants.expectedUpdatedDate),
                   "UpdatedAt should be \(DateFormatter().RFC3339(Constants.expectedUpdatedDate)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, Constants.expectedStatus.rawValue,
                   "Status should be \(Constants.expectedStatus.rawValue) but was \(challenge.status.rawValue)")
    XCTAssertNil(challenge.response, "Response should be nil")
    XCTAssertEqual(challenge.challengeDetails.message, Constants.expectedMessage,
                   "Detail message should be \(Constants.expectedMessage) but was \(challenge.challengeDetails.message)")
    XCTAssertEqual(challenge.challengeDetails.fields.count, fields.count,
                   "Detail fields count should be \(fields.count) but was \(challenge.challengeDetails.fields.count)")
    XCTAssertEqual(challenge.challengeDetails.date, DateFormatter().RFC3339(Constants.expectedDateValue),
                   "Detail date should be \(DateFormatter().RFC3339(Constants.expectedDateValue)!) but was \(challenge.challengeDetails.date!)")
    XCTAssertEqual(challenge.hiddenDetails, hiddenDetails,
                   "Hidden details should be \(hiddenDetails) but was \(challenge.hiddenDetails!)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(Constants.expectedExpirationDate),
                   "Expiration date should be \(DateFormatter().RFC3339(Constants.expectedExpirationDate)!) but was \(challenge.expirationDate)")
    XCTAssertNil(challenge.signatureFields, "Signature fields should be nil")
  }
  
  func testFromAPI_withResponseWithoutSid_shouldThrow() {
    let fields = [Detail(label: Constants.expectedLabel1, value: Constants.expectedValue1),
                  Detail(label: Constants.expectedLabel2, value: Constants.expectedValue1)]
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: fields,
      date: Constants.expectedDateValue)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedStatus,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
    var challengeData = try! JSONEncoder().encode(challengeDTO)
    var expectedChallengeResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    expectedChallengeResponse.remove(at: expectedChallengeResponse.index(forKey: expectedChallengeResponse.first { _, value in
      return (value as? String) == Constants.expectedSidValue
      }!.key)!)
    challengeData = try! JSONSerialization.data(withJSONObject: expectedChallengeResponse, options: [])
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.errorDescription, TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription,
                   "Error should be \(TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription!) but was \(error.errorDescription!)")
  }
  
  func testFromAPI_withResponseWithoutDetails_shouldThrow() {
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: [],
      date: nil)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedStatus,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
    var challengeData = try! JSONEncoder().encode(challengeDTO)
    var expectedChallengeResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    expectedChallengeResponse.remove(at: expectedChallengeResponse.index(forKey: ChallengeDTO.CodingKeys.details.rawValue)!)
    challengeData = try! JSONSerialization.data(withJSONObject: expectedChallengeResponse, options: [])
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.errorDescription, TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription,
                   "Error should be \(TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription!) but was \(error.errorDescription!)")
  }
  
  func testFromAPI_withResponseWithoutDetailsMessage_shouldThrow() {
    let fields = [Detail(label: Constants.expectedLabel1, value: Constants.expectedValue1),
    Detail(label: Constants.expectedLabel2, value: Constants.expectedValue1)]
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: fields,
      date: nil)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedStatus,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
    var challengeData = try! JSONEncoder().encode(challengeDTO)
    var expectedChallengeResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    var expectedDetails = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(detailsDTO), options: []) as! [String: Any]
    expectedDetails.remove(at: expectedDetails.index(forKey: expectedDetails.first { _, value in
      return (value as? String) == Constants.expectedMessage
    }!.key)!)
    expectedChallengeResponse[ChallengeDTO.CodingKeys.details.rawValue] = expectedDetails
    challengeData = try! JSONSerialization.data(withJSONObject: expectedChallengeResponse, options: [])
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.errorDescription, TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription,
                   "Error should be \(TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription!) but was \(error.errorDescription!)")
  }
  
  func testFromAPI_withInvalidCreatedDate_shouldThrow() {
    let fields = [Detail(label: Constants.expectedLabel1, value: Constants.expectedValue1),
                  Detail(label: Constants.expectedLabel2, value: Constants.expectedValue1)]
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: fields,
      date: Constants.expectedDateValue)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedStatus,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: "19-02-2020",
      updateAt: Constants.expectedUpdatedDate)
    let challengeData = try! JSONEncoder().encode(challengeDTO)
    let expectedChallengeResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.originalError as! MapperError, MapperError.invalidDate,
                   "Error should be \(MapperError.invalidDate) but was \(error.originalError)")
  }
  
  func testFromAPI_withInvalidUpdatedDate_shouldThrow() {
    let fields = [Detail(label: Constants.expectedLabel1, value: Constants.expectedValue1),
                  Detail(label: Constants.expectedLabel2, value: Constants.expectedValue1)]
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: fields,
      date: Constants.expectedDateValue)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedStatus,
      expirationDate: Constants.expectedExpirationDate,
      createdAt: Constants.expectedCreatedDate,
      updateAt: "19-02-2020")
    let challengeData = try! JSONEncoder().encode(challengeDTO)
    let expectedChallengeResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.originalError as! MapperError, MapperError.invalidDate,
                   "Error should be \(MapperError.invalidDate) but was \(error.originalError)")
  }
  
  func testFromAPI_withInvalidExpirationDate_shouldThrow() {
    let fields = [Detail(label: Constants.expectedLabel1, value: Constants.expectedValue1),
                  Detail(label: Constants.expectedLabel2, value: Constants.expectedValue1)]
    let detailsDTO = ChallengeDetailsDTO(
      message: Constants.expectedMessage,
      fields: fields,
      date: Constants.expectedDateValue)
    let hiddenDetails = [Constants.expectedKey1: Constants.expectedValue1]
    let challengeDTO = ChallengeDTO(
      sid: Constants.expectedSidValue,
      details: detailsDTO,
      hiddenDetails: hiddenDetails,
      factorSid: Constants.expectedFactorSid,
      status: Constants.expectedStatus,
      expirationDate: "19-02-2020",
      createdAt: Constants.expectedCreatedDate,
      updateAt: Constants.expectedUpdatedDate)
    let challengeData = try! JSONEncoder().encode(challengeDTO)
    let expectedChallengeResponse = try! JSONSerialization.jsonObject(with: challengeData, options: []) as! [String: Any]
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.originalError as! MapperError, MapperError.invalidDate,
                   "Error should be \(MapperError.invalidDate) but was \(error.originalError)")
  }
}

private extension ChallengeMapperTests {
  struct Constants {
    static let expectedSidValue = "sid123"
    static let expectedStatus = ChallengeStatus.pending
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
    static let expectedKey1 = "Key1"
  }
}
