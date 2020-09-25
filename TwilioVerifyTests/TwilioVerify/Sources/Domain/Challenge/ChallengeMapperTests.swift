//
//  ChallengeMapperTests.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
    let details: [String: Any] = [Constants.messageKey: Constants.expectedMessage,
                                   Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                         [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]],
                                   Constants.dateKey: Constants.expectedDateValue]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue,
                                     Constants.detailsKey: detailsString,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: Constants.expectedExpirationDate]

    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    var challenge: FactorChallenge!
    XCTAssertNoThrow(challenge = try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader),
                     "Mapping from API should not throw")
    XCTAssertEqual(challenge.sid, expectedChallengeResponse[Constants.sidKey],
                   "Sid should be \(expectedChallengeResponse[Constants.sidKey]!!) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, expectedChallengeResponse[Constants.factorSidKey],
                   "FactorSid should be \(expectedChallengeResponse[Constants.factorSidKey]!!) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(expectedChallengeResponse[Constants.createdDateKey]!!),
                   "CreatedAt should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.createdDateKey]!!)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(expectedChallengeResponse[Constants.updatedDateKey]!!),
                   "UpdatedAt should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.updatedDateKey]!!)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, expectedChallengeResponse[Constants.statusKey],
                   "Status should be \(expectedChallengeResponse[Constants.statusKey]!!) but was \(challenge.status.rawValue)")
    XCTAssertEqual(challenge.response?.keys.count, expectedChallengeResponse.keys.count,
                   "Response should be \(expectedChallengeResponse) but was \(challenge.response!)")
    XCTAssertEqual(challenge.challengeDetails.message, details[Constants.messageKey] as! String,
                   "Detail message should be \(details[Constants.messageKey] as! String) but was \(challenge.challengeDetails.message)")
    XCTAssertEqual(challenge.challengeDetails.fields.count, (details[Constants.fieldsKey] as! [[String: String]]).count,
                   "Detail fields count should be \((details[Constants.fieldsKey] as! [[String: String]]).count) but was \(challenge.challengeDetails.fields.count)")
    XCTAssertEqual(challenge.challengeDetails.date, DateFormatter().RFC3339(details[Constants.dateKey]! as! String),
                   "Detail date should be \(DateFormatter().RFC3339(details[Constants.dateKey]! as! String)!) but was \(challenge.challengeDetails.date!)")
    XCTAssertEqual(challenge.hiddenDetails, hiddenDetailsString,
                   "Hidden details should be \(hiddenDetailsString!) but was \(challenge.hiddenDetails)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(expectedChallengeResponse[Constants.expirationDateKey]!!),
                   "Expiration date should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.expirationDateKey]!!)!) but was \(challenge.expirationDate)")
    XCTAssertEqual(challenge.signatureFields?.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator), expectedSignatureFieldsHeader,
                   "Signature fields should be \(expectedSignatureFieldsHeader) but was \(challenge.signatureFields!.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator))")
  }
  
  func testFromAPI_withValidResponseWithoutFields_shouldReturnChallenge() {
    let details: [String: Any] = [Constants.messageKey: Constants.expectedMessage,
                                   Constants.dateKey: Constants.expectedDateValue]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue,
                                     Constants.detailsKey: detailsString,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: Constants.expectedExpirationDate]
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    var challenge: FactorChallenge!
    XCTAssertNoThrow(challenge = try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader),
                     "Mapping from API should not throw")
    XCTAssertEqual(challenge.sid, expectedChallengeResponse[Constants.sidKey],
                   "Sid should be \(expectedChallengeResponse[Constants.sidKey]!!) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, expectedChallengeResponse[Constants.factorSidKey],
                   "FactorSid should be \(expectedChallengeResponse[Constants.factorSidKey]!!) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(expectedChallengeResponse[Constants.createdDateKey]!!),
                   "CreatedAt should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.createdDateKey]!!)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(expectedChallengeResponse[Constants.updatedDateKey]!!),
                   "UpdatedAt should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.updatedDateKey]!!)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, expectedChallengeResponse[Constants.statusKey],
                   "Status should be \(expectedChallengeResponse[Constants.statusKey]!!) but was \(challenge.status.rawValue)")
    XCTAssertEqual(challenge.response?.keys.count, expectedChallengeResponse.keys.count,
                   "Response should be \(expectedChallengeResponse) but was \(challenge.response!)")
    XCTAssertEqual(challenge.challengeDetails.message, details[Constants.messageKey] as! String,
                   "Detail message should be \(details[Constants.messageKey] as! String) but was \(challenge.challengeDetails.message)")
    XCTAssertTrue(challenge.challengeDetails.fields.isEmpty, "Detail fields should be empty")
    XCTAssertEqual(challenge.challengeDetails.date, DateFormatter().RFC3339(details[Constants.dateKey]! as! String),
                   "Detail date should be \(DateFormatter().RFC3339(details[Constants.dateKey]! as! String)!) but was \(challenge.challengeDetails.date!)")
    XCTAssertEqual(challenge.hiddenDetails, hiddenDetailsString,
                   "Hidden details should be \(hiddenDetailsString!) but was \(challenge.hiddenDetails)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(expectedChallengeResponse[Constants.expirationDateKey]!!),
                   "Expiration date should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.expirationDateKey]!!)!) but was \(challenge.expirationDate)")
    XCTAssertEqual(challenge.signatureFields?.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator), expectedSignatureFieldsHeader,
                   "Signature fields should be \(expectedSignatureFieldsHeader) but was \(challenge.signatureFields!.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator))")
  }
  
  func testFromAPI_withValidResponseWithoutDetailsDate_shouldReturnChallenge() {
    let details: [String: Any] = [Constants.messageKey: Constants.expectedMessage,
                                   Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                         [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]]]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue,
                                     Constants.detailsKey: detailsString,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: Constants.expectedExpirationDate]
    
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    var challenge: FactorChallenge!
    XCTAssertNoThrow(challenge = try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader),
                     "Mapping from API should not throw")
    XCTAssertEqual(challenge.sid, expectedChallengeResponse[Constants.sidKey],
                   "Sid should be \(expectedChallengeResponse[Constants.sidKey]!!) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, expectedChallengeResponse[Constants.factorSidKey],
                   "FactorSid should be \(expectedChallengeResponse[Constants.factorSidKey]!!) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(expectedChallengeResponse[Constants.createdDateKey]!!),
                   "CreatedAt should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.createdDateKey]!!)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(expectedChallengeResponse[Constants.updatedDateKey]!!),
                   "UpdatedAt should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.updatedDateKey]!!)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, expectedChallengeResponse[Constants.statusKey],
                   "Status should be \(expectedChallengeResponse[Constants.statusKey]!!) but was \(challenge.status.rawValue)")
    XCTAssertEqual(challenge.response?.keys.count, expectedChallengeResponse.keys.count,
                   "Response should be \(expectedChallengeResponse) but was \(challenge.response!)")
    XCTAssertEqual(challenge.challengeDetails.message, details[Constants.messageKey] as! String,
                   "Detail message should be \(details[Constants.messageKey] as! String) but was \(challenge.challengeDetails.message)")
    XCTAssertEqual(challenge.challengeDetails.fields.count, (details[Constants.fieldsKey] as! [[String: String]]).count,
                   "Detail fields count should be \((details[Constants.fieldsKey] as! [[String: String]]).count) but was \(challenge.challengeDetails.fields.count)")
    XCTAssertNil(challenge.challengeDetails.date, "Details date should be nil")
    XCTAssertEqual(challenge.hiddenDetails, hiddenDetailsString,
                   "Hidden details should be \(hiddenDetailsString!) but was \(challenge.hiddenDetails)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(expectedChallengeResponse[Constants.expirationDateKey]!!),
                   "Expiration date should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.expirationDateKey]!!)!) but was \(challenge.expirationDate)")
    XCTAssertEqual(challenge.signatureFields?.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator), expectedSignatureFieldsHeader,
                   "Signature fields should be \(expectedSignatureFieldsHeader) but was \(challenge.signatureFields!.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator))")
  }
  
  func testFromAPI_withValidResponseAndApprovedStatus_shouldReturnChallenge() {
    let details: [String: Any] = [Constants.messageKey: Constants.expectedMessage,
                                   Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                         [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]],
                                   Constants.dateKey: Constants.expectedDateValue]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.approved.rawValue,
                                     Constants.detailsKey: detailsString,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: Constants.expectedExpirationDate]
    
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    var challenge: FactorChallenge!
    XCTAssertNoThrow(challenge = try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader),
                     "Mapping from API should not throw")
    XCTAssertEqual(challenge.sid, expectedChallengeResponse[Constants.sidKey],
                   "Sid should be \(expectedChallengeResponse[Constants.sidKey]!!) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, expectedChallengeResponse[Constants.factorSidKey],
                   "FactorSid should be \(expectedChallengeResponse[Constants.factorSidKey]!!) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(expectedChallengeResponse[Constants.createdDateKey]!!),
                   "CreatedAt should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.createdDateKey]!!)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(expectedChallengeResponse[Constants.updatedDateKey]!!),
                   "UpdatedAt should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.updatedDateKey]!!)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, expectedChallengeResponse[Constants.statusKey],
                   "Status should be \(expectedChallengeResponse[Constants.statusKey]!!) but was \(challenge.status.rawValue)")
    XCTAssertNil(challenge.response, "Response should be nil")
    XCTAssertEqual(challenge.challengeDetails.message, details[Constants.messageKey] as! String,
                   "Detail message should be \(details[Constants.messageKey] as! String) but was \(challenge.challengeDetails.message)")
    XCTAssertEqual(challenge.challengeDetails.fields.count, (details[Constants.fieldsKey] as! [[String: String]]).count,
                   "Detail fields count should be \((details[Constants.fieldsKey] as! [[String: String]]).count) but was \(challenge.challengeDetails.fields.count)")
    XCTAssertEqual(challenge.challengeDetails.date, DateFormatter().RFC3339(details[Constants.dateKey]! as! String),
                   "Detail date should be \(DateFormatter().RFC3339(details[Constants.dateKey]! as! String)!) but was \(challenge.challengeDetails.date!)")
    XCTAssertEqual(challenge.hiddenDetails, hiddenDetailsString,
                   "Hidden details should be \(hiddenDetailsString!) but was \(challenge.hiddenDetails)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(expectedChallengeResponse[Constants.expirationDateKey]!!),
                   "Expiration date should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.expirationDateKey]!!)!) but was \(challenge.expirationDate)")
    XCTAssertNil(challenge.signatureFields, "Signature fields should be nil")
  }
  
  func testFromAPI_withValidResponseWithPendingStatusAndNoSignatureFields_shouldReturnChallenge() {
    let details: [String: Any] = [Constants.messageKey: Constants.expectedMessage,
                                   Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                         [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]],
                                   Constants.dateKey: Constants.expectedDateValue]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue,
                                     Constants.detailsKey: detailsString,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: Constants.expectedExpirationDate]
    
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    var challenge: FactorChallenge!
    XCTAssertNoThrow(challenge = try mapper.fromAPI(withData: challengeData), "Mapping from API should not throw")
    XCTAssertEqual(challenge.sid, expectedChallengeResponse[Constants.sidKey],
                   "Sid should be \(expectedChallengeResponse[Constants.sidKey]!!) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, expectedChallengeResponse[Constants.factorSidKey],
                   "FactorSid should be \(expectedChallengeResponse[Constants.factorSidKey]!!) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.createdAt, DateFormatter().RFC3339(expectedChallengeResponse[Constants.createdDateKey]!!),
                   "CreatedAt should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.createdDateKey]!!)!) but was \(challenge.createdAt)")
    XCTAssertEqual(challenge.updatedAt, DateFormatter().RFC3339(expectedChallengeResponse[Constants.updatedDateKey]!!),
                   "UpdatedAt should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.updatedDateKey]!!)!) but was \(challenge.updatedAt)")
    XCTAssertEqual(challenge.status.rawValue, expectedChallengeResponse[Constants.statusKey],
                   "Status should be \(expectedChallengeResponse[Constants.statusKey]!!) but was \(challenge.status.rawValue)")
    XCTAssertNil(challenge.response, "Response should be nil")
    XCTAssertEqual(challenge.challengeDetails.message, details[Constants.messageKey] as! String,
                   "Detail message should be \(details[Constants.messageKey] as! String) but was \(challenge.challengeDetails.message)")
    XCTAssertEqual(challenge.challengeDetails.fields.count, (details[Constants.fieldsKey] as! [[String: String]]).count,
                   "Detail fields count should be \((details[Constants.fieldsKey] as! [[String: String]]).count) but was \(challenge.challengeDetails.fields.count)")
    XCTAssertEqual(challenge.challengeDetails.date, DateFormatter().RFC3339(details[Constants.dateKey]! as! String),
                   "Detail date should be \(DateFormatter().RFC3339(details[Constants.dateKey]! as! String)!) but was \(challenge.challengeDetails.date!)")
    XCTAssertEqual(challenge.hiddenDetails, hiddenDetailsString,
                   "Hidden details should be \(hiddenDetailsString!) but was \(challenge.hiddenDetails)")
    XCTAssertEqual(challenge.expirationDate, DateFormatter().RFC3339(expectedChallengeResponse[Constants.expirationDateKey]!!),
                   "Expiration date should be \(DateFormatter().RFC3339(expectedChallengeResponse[Constants.expirationDateKey]!!)!) but was \(challenge.expirationDate)")
    XCTAssertNil(challenge.signatureFields, "Signature fields should be nil")
  }
  
  func testFromAPI_withResponseWithoutSid_shouldThrow() {
    let details: [String: Any] = [Constants.messageKey: Constants.expectedMessage,
                                   Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                         [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]],
                                   Constants.dateKey: Constants.expectedDateValue]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue,
                                     Constants.detailsKey: detailsString,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: Constants.expectedExpirationDate]
    
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.errorDescription, TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription,
                   "Error should be \(TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription!) but was \(error.errorDescription!)")
  }
  
  func testFromAPI_withResponseWithoutDetails_shouldThrow() {
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: Constants.expectedExpirationDate]
    
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.errorDescription, TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription,
                   "Error should be \(TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription!) but was \(error.errorDescription!)")
  }
  
  func testFromAPI_withResponseWithoutDetailsMessage_shouldThrow() {
    let details: [String: Any] = [Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                         [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]],
                                   Constants.dateKey: Constants.expectedDateValue]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue,
                                     Constants.detailsKey: detailsString,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: Constants.expectedExpirationDate]
    
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.errorDescription, TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription,
                   "Error should be \(TwilioVerifyError.mapperError(error: TestError.operationFailed as NSError).errorDescription!) but was \(error.errorDescription!)")
  }
  
  func testFromAPI_withInvalidCreatedDate_shouldThrow() {
    let details: [String: Any] = [Constants.messageKey: Constants.expectedMessage,
                                   Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                         [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]],
                                   Constants.dateKey: Constants.expectedDateValue]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: "19-02-2020",
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue,
                                     Constants.detailsKey: detailsString,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: Constants.expectedExpirationDate]
    
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.originalError as! MapperError, MapperError.invalidDate,
                   "Error should be \(MapperError.invalidDate) but was \(error.originalError)")
  }
  
  func testFromAPI_withInvalidUpdatedDate_shouldThrow() {
    let details: [String: Any] = [Constants.messageKey: Constants.expectedMessage,
                                   Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                         [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]],
                                   Constants.dateKey: Constants.expectedDateValue]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: "19-02-2020",
                                     Constants.statusKey: ChallengeStatus.pending.rawValue,
                                     Constants.detailsKey: detailsString,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: Constants.expectedExpirationDate]
    
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
    var error: TwilioVerifyError!
    XCTAssertThrowsError(try mapper.fromAPI(withData: challengeData, signatureFieldsHeader: expectedSignatureFieldsHeader), "Mapping from API should throw") { failure in
      error = failure as? TwilioVerifyError
    }
    XCTAssertEqual(error.originalError as! MapperError, MapperError.invalidDate,
                   "Error should be \(MapperError.invalidDate) but was \(error.originalError)")
  }
  
  func testFromAPI_withInvalidExpirationDate_shouldThrow() {
    let details: [String: Any] = [Constants.messageKey: Constants.expectedMessage,
                                   Constants.fieldsKey: [[Constants.labelKey: Constants.expectedLabel1, Constants.valueKey: Constants.expectedValue1],
                                                         [Constants.labelKey: Constants.expectedLabel2, Constants.valueKey: Constants.expectedValue1]],
                                   Constants.dateKey: Constants.expectedDateValue]
    let detailsString = try! String(data: JSONSerialization.data(withJSONObject: details, options: []), encoding: String.Encoding.ascii)!
    let hiddenDetails = [Constants.labelKey: Constants.expectedLabel1]
    let hiddenDetailsString = try! String(data: JSONEncoder().encode(hiddenDetails), encoding: .utf8)
    let expectedChallengeResponse = [Constants.sidKey: Constants.expectedSidValue,
                                     Constants.factorSidKey: Constants.expectedFactorSid,
                                     Constants.createdDateKey: Constants.expectedCreatedDate,
                                     Constants.updatedDateKey: Constants.expectedUpdatedDate,
                                     Constants.statusKey: ChallengeStatus.pending.rawValue,
                                     Constants.detailsKey: detailsString,
                                     Constants.hiddenDetailsKey: hiddenDetailsString,
                                     Constants.expirationDateKey: "19-02-2020"]
    
    let expectedSignatureFieldsHeader = expectedChallengeResponse.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let challengeData = try! JSONEncoder().encode(expectedChallengeResponse)
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
    static let sidKey = "sid"
    static let factorSidKey = "factor_sid"
    static let createdDateKey = "date_created"
    static let updatedDateKey = "date_updated"
    static let statusKey = "status"
    static let detailsKey = "details"
    static let hiddenDetailsKey = "hidden_details"
    static let expirationDateKey = "expiration_date"
    static let messageKey = "message"
    static let fieldsKey = "fields"
    static let labelKey = "label"
    static let valueKey = "value"
    static let dateKey = "date"
    static let expectedSidValue = "sid123"
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
  }
}
