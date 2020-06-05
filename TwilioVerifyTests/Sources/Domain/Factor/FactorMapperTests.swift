//
//  FactorMapperTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/5/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class FactorMapperTests: XCTestCase {
  
  override func setUpWithError() throws {
    try super.setUpWithError()
  }
  
  func testMap_withValidResponseFromAPI_shouldReturnFactor() {
    let expectedFactorResponse: [String: Any] = [
      Constants.sidKey: Constants.expectedSidValue,
      Constants.friendlyNameKey: Constants.expectedFriendlyName,
      Constants.accountSidKey: Constants.expectedAccountSid,
      Constants.statusKey: FactorStatus.unverified.rawValue,
      Constants.configKey: [
        Constants.credentialSidKey: Constants.expectedCredentialSid
      ],
      Constants.dateCreatedKey: Constants.expectedDate
    ]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let mapper = FactorMapper()
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            entity: Constants.entityIdentityValue, config: [:], binding: [:], jwe: Constants.jweValue)
    var factor: Factor!
    XCTAssertNoThrow(factor = try mapper.fromAPI(withData: data, factorPayload: factorPayload), "Factor mapper should succeed")
    XCTAssertEqual(factor.type, factorPayload.type, "Factor type should be \(factorPayload.type) but was \(factor.type)")
    XCTAssertEqual(factor.serviceSid, factorPayload.serviceSid, "Factor serviceSid should be \(factorPayload.serviceSid) but was \(factor.serviceSid)")
    XCTAssertEqual(factor.entityIdentity, factorPayload.entity, "Factor entity should be \(factorPayload.entity) but was \(factor.entityIdentity)")
    XCTAssertEqual(factor.sid, expectedFactorResponse[Constants.sidKey] as! String,
                   "Factor sid should be \(expectedFactorResponse[Constants.sidKey] as! String) but was \(factor.sid)")
    XCTAssertEqual(factor.friendlyName, expectedFactorResponse[Constants.friendlyNameKey] as! String,
                   "Factor friendlyName should be \(expectedFactorResponse[Constants.friendlyNameKey] as! String) but was \(factor.friendlyName)")
    XCTAssertEqual(factor.accountSid, expectedFactorResponse[Constants.accountSidKey] as! String,
                   "Factor accountSid should be \(expectedFactorResponse[Constants.accountSidKey] as! String) but was \(factor.accountSid)")
    XCTAssertEqual(factor.status.rawValue, expectedFactorResponse[Constants.statusKey] as! String,
                   "Factor status should be \(expectedFactorResponse[Constants.statusKey] as! String) but was \(factor.status)")
    XCTAssertEqual(factor.createdAt, DateParser.parse(RFC3339String: expectedFactorResponse[Constants.dateCreatedKey] as! String),
                   "Factor createdAt should be \(expectedFactorResponse[Constants.dateCreatedKey] as! String) but was \(factor.createdAt)")
  }
  
  func testMap_withIncompleteResponseFromAPI_shouldThrow() {
    let expectedFactorResponse: [String: Any] = [
      Constants.friendlyNameKey: Constants.expectedFriendlyName,
      Constants.accountSidKey: Constants.expectedAccountSid
    ]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let mapper = FactorMapper()
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            entity: Constants.entityIdentityValue, config: [:], binding: [:], jwe: Constants.jweValue)
    XCTAssertThrowsError(try mapper.fromAPI(withData: data, factorPayload: factorPayload)) { error in
      XCTAssertEqual((error as! TwilioVerifyError).errorDescription, TwilioVerifyError.mapperError(error: NSError()).errorDescription)
    }
  }
  
  func testMap_withInvalidServiceSidInPayload_shouldThrow() {
    let expectedFactorResponse: [String: Any] = [
      Constants.friendlyNameKey: Constants.expectedFriendlyName,
      Constants.accountSidKey: Constants.expectedAccountSid
    ]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let mapper = FactorMapper()
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: "",
                                            entity: Constants.entityIdentityValue, config: [:], binding: [:], jwe: Constants.jweValue)
    XCTAssertThrowsError(try mapper.fromAPI(withData: data, factorPayload: factorPayload)) { error in
      XCTAssertEqual(((error as! TwilioVerifyError).originalError as! MapperError), MapperError.invalidArgument)
    }
  }
  
  func testMap_withInvalidEntityInPayload_shouldThrow() {
    let expectedFactorResponse: [String: Any] = [
      Constants.friendlyNameKey: Constants.expectedFriendlyName,
      Constants.accountSidKey: Constants.expectedAccountSid
    ]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let mapper = FactorMapper()
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            entity: "", config: [:], binding: [:], jwe: Constants.jweValue)
    XCTAssertThrowsError(try mapper.fromAPI(withData: data, factorPayload: factorPayload)) { error in
      XCTAssertEqual(((error as! TwilioVerifyError).originalError as! MapperError), MapperError.invalidArgument)
    }
  }
  
  func testMap_withInvalidDateResponseFromAPI_shouldThrow() {
    let expectedFactorResponse: [String: Any] = [
      Constants.sidKey: Constants.expectedSidValue,
      Constants.friendlyNameKey: Constants.expectedFriendlyName,
      Constants.accountSidKey: Constants.expectedAccountSid,
      Constants.statusKey: FactorStatus.unverified.rawValue,
      Constants.configKey: [
        Constants.credentialSidKey: Constants.expectedCredentialSid
      ],
      Constants.dateCreatedKey: "2020/06/01"
    ]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let mapper = FactorMapper()
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            entity: Constants.entityIdentityValue, config: [:], binding: [:], jwe: Constants.jweValue)
    XCTAssertThrowsError(try mapper.fromAPI(withData: data, factorPayload: factorPayload)) { error in
      XCTAssertEqual(((error as! TwilioVerifyError).originalError as! MapperError), MapperError.invalidDate)
    }
  }
}

private extension FactorMapperTests {
  struct Constants {
    static let sidKey = "sid"
    static let friendlyNameKey = "friendly_name"
    static let accountSidKey = "account_sid"
    static let statusKey = "status"
    static let dateCreatedKey = "date_created"
    static let configKey = "config"
    static let credentialSidKey = "credential_sid"
    static let pushType = FactorType.push
    static let friendlyNameValue = "factor name"
    static let serviceSidValue = "serviceSid123"
    static let entityIdentityValue = "entityId123"
    static let jweValue = "jwe"
    static let expectedSidValue = "sid123"
    static let expectedFriendlyName = "push_factor"
    static let expectedAccountSid = "accountSid123"
    static let expectedCredentialSid = "credentialSid123"
    static let expectedDate = "2020-06-05T15:57:47Z"
  }
}
