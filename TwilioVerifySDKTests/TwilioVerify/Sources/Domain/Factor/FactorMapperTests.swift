//
//  FactorMapperTests.swift
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
class FactorMapperTests: XCTestCase {
  
  private var mapper: FactorMapper!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    mapper = FactorMapper()
  }
  
  func testFromAPI_withValidResponse_shouldReturnFactor() {
    let expectedFactorResponse: [String: Any] = [Constants.sidKey: Constants.expectedSidValue,
                                                 Constants.friendlyNameKey: Constants.expectedFriendlyName,
                                                 Constants.accountSidKey: Constants.expectedAccountSid,
                                                 Constants.statusKey: FactorStatus.unverified.rawValue,
                                                 Constants.configKey: [Constants.credentialSidKey: Constants.expectedCredentialSid],
                                                 Constants.dateCreatedKey: Constants.expectedDate]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            identity: Constants.identityValue, config: [:], binding: [:], accessToken: Constants.accessToken, metadata: nil)
    var factor: Factor!
    XCTAssertNoThrow(factor = try mapper.fromAPI(withData: data, factorPayload: factorPayload), "Factor mapper should succeed")
    XCTAssertEqual(factor.type, factorPayload.type, "Factor type should be \(factorPayload.type) but was \(factor.type)")
    XCTAssertEqual(factor.serviceSid, factorPayload.serviceSid, "Factor serviceSid should be \(factorPayload.serviceSid) but was \(factor.serviceSid)")
    XCTAssertEqual(factor.identity, factorPayload.identity, "Factor identity should be \(factorPayload.identity) but was \(factor.identity)")
    XCTAssertEqual(factor.sid, expectedFactorResponse[Constants.sidKey] as! String,
                   "Factor sid should be \(expectedFactorResponse[Constants.sidKey] as! String) but was \(factor.sid)")
    XCTAssertEqual(factor.friendlyName, expectedFactorResponse[Constants.friendlyNameKey] as! String,
                   "Factor friendlyName should be \(expectedFactorResponse[Constants.friendlyNameKey] as! String) but was \(factor.friendlyName)")
    XCTAssertEqual(factor.accountSid, expectedFactorResponse[Constants.accountSidKey] as! String,
                   "Factor accountSid should be \(expectedFactorResponse[Constants.accountSidKey] as! String) but was \(factor.accountSid)")
    XCTAssertEqual(factor.status.rawValue, expectedFactorResponse[Constants.statusKey] as! String,
                   "Factor status should be \(expectedFactorResponse[Constants.statusKey] as! String) but was \(factor.status)")
    XCTAssertEqual(factor.createdAt, DateFormatter().RFC3339(expectedFactorResponse[Constants.dateCreatedKey] as! String),
                   "Factor createdAt should be \(expectedFactorResponse[Constants.dateCreatedKey] as! String) but was \(factor.createdAt)")
    XCTAssertEqual((factor as! PushFactor).config.notificationPlatform, NotificationPlatform.apn,
                   "Factor notification platform should be \(NotificationPlatform.apn) but was \((factor as! PushFactor).config.notificationPlatform)")
  }
  
  func testFromAPI_withValidResponseAndNotificationPlatformNone_shouldReturnFactor() {
    let config = [Constants.credentialSidKey: Constants.expectedCredentialSid,
                  Constants.notificationPlatformKey: Constants.expectedNotificationPlatform]
    let expectedFactorResponse: [String: Any] = [Constants.sidKey: Constants.expectedSidValue,
                                                 Constants.friendlyNameKey: Constants.expectedFriendlyName,
                                                 Constants.accountSidKey: Constants.expectedAccountSid,
                                                 Constants.statusKey: FactorStatus.unverified.rawValue,
                                                 Constants.configKey: config,
                                                 Constants.dateCreatedKey: Constants.expectedDate]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            identity: Constants.identityValue, config: [:], binding: [:], accessToken: Constants.accessToken, metadata: nil)
    var factor: Factor!
    XCTAssertNoThrow(factor = try mapper.fromAPI(withData: data, factorPayload: factorPayload), "Factor mapper should succeed")
    XCTAssertEqual(factor.type, factorPayload.type, "Factor type should be \(factorPayload.type) but was \(factor.type)")
    XCTAssertEqual((factor as! PushFactor).config.notificationPlatform, NotificationPlatform.none,
                   "Factor notification platform should be \(NotificationPlatform.apn) but was \((factor as! PushFactor).config.notificationPlatform)")
  }
  
  func testFromAPI_withValidResponseAndMetadata_shouldReturnFactor() {
    let config = [Constants.credentialSidKey: Constants.expectedCredentialSid,
                  Constants.notificationPlatformKey: Constants.expectedNotificationPlatform]
    let expectedFactorResponse: [String: Any] = [Constants.sidKey: Constants.expectedSidValue,
                                                 Constants.friendlyNameKey: Constants.expectedFriendlyName,
                                                 Constants.accountSidKey: Constants.expectedAccountSid,
                                                 Constants.statusKey: FactorStatus.unverified.rawValue,
                                                 Constants.configKey: config,
                                                 Constants.dateCreatedKey: Constants.expectedDate,
                                                 Constants.metadataKey: Constants.expectedMetadata]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            identity: Constants.identityValue, config: [:], binding: [:], accessToken: Constants.accessToken, metadata: nil)
    var factor: Factor!
    XCTAssertNoThrow(factor = try mapper.fromAPI(withData: data, factorPayload: factorPayload), "Factor mapper should succeed")
    XCTAssertEqual(factor.type, factorPayload.type, "Factor type should be \(factorPayload.type) but was \(factor.type)")
    XCTAssertEqual(factor.metadata, Constants.expectedMetadata,
                   "Factor metadata should be \(Constants.expectedMetadata) but was \(factor.metadata)")
  }
  
  func testFromAPI_withValidResponseAndInvalidNotificationPlatform_shouldReturnFactor() {
    let config = [Constants.credentialSidKey: Constants.expectedCredentialSid,
                  Constants.notificationPlatformKey: "invalid"]
    let expectedFactorResponse: [String: Any] = [Constants.sidKey: Constants.expectedSidValue,
                                                 Constants.friendlyNameKey: Constants.expectedFriendlyName,
                                                 Constants.accountSidKey: Constants.expectedAccountSid,
                                                 Constants.statusKey: FactorStatus.unverified.rawValue,
                                                 Constants.configKey: config,
                                                 Constants.dateCreatedKey: Constants.expectedDate]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            identity: Constants.identityValue, config: [:], binding: [:], accessToken: Constants.accessToken, metadata: nil)
    var factor: Factor!
    XCTAssertNoThrow(factor = try mapper.fromAPI(withData: data, factorPayload: factorPayload), "Factor mapper should succeed")
    XCTAssertEqual(factor.type, factorPayload.type, "Factor type should be \(factorPayload.type) but was \(factor.type)")
    XCTAssertEqual((factor as! PushFactor).config.notificationPlatform, NotificationPlatform.apn,
                   "Factor notification platform should be \(NotificationPlatform.apn) but was \((factor as! PushFactor).config.notificationPlatform)")
  }
  
  func testFromAPI_withIncompleteResponse_shouldThrow() {
    let expectedFactorResponse = [Constants.friendlyNameKey: Constants.expectedFriendlyName,
                                  Constants.accountSidKey: Constants.expectedAccountSid]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            identity: Constants.identityValue, config: [:], binding: [:], accessToken: Constants.accessToken, metadata: nil)
    XCTAssertThrowsError(try mapper.fromAPI(withData: data, factorPayload: factorPayload)) { error in
      XCTAssertEqual((error as! TwilioVerifyError).errorDescription, TwilioVerifyError.mapperError(error: NSError()).errorDescription)
    }
  }
  
  func testFromAPI_withInvalidServiceSidInPayload_shouldThrow() {
    let expectedFactorResponse = [Constants.friendlyNameKey: Constants.expectedFriendlyName,
                                  Constants.accountSidKey: Constants.expectedAccountSid]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: "",
                                            identity: Constants.identityValue, config: [:], binding: [:], accessToken: Constants.accessToken, metadata: nil)
    XCTAssertThrowsError(try mapper.fromAPI(withData: data, factorPayload: factorPayload)) { error in
      XCTAssertEqual(((error as! TwilioVerifyError).originalError as! MapperError), MapperError.invalidArgument)
    }
  }
  
  func testFromAPI_withInvalidIdentityInPayload_shouldThrow() {
    let expectedFactorResponse = [Constants.friendlyNameKey: Constants.expectedFriendlyName,
                                  Constants.accountSidKey: Constants.expectedAccountSid]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            identity: "", config: [:], binding: [:], accessToken: Constants.accessToken, metadata: nil)
    XCTAssertThrowsError(try mapper.fromAPI(withData: data, factorPayload: factorPayload)) { error in
      XCTAssertEqual(((error as! TwilioVerifyError).originalError as! MapperError), MapperError.invalidArgument)
    }
  }
  
  func testFromAPI_withInvalidDateResponse_shouldThrow() {
    let expectedFactorResponse: [String: Any] = [Constants.sidKey: Constants.expectedSidValue,
                                                 Constants.friendlyNameKey: Constants.expectedFriendlyName,
                                                 Constants.accountSidKey: Constants.expectedAccountSid,
                                                 Constants.statusKey: FactorStatus.unverified.rawValue,
                                                 Constants.configKey: [Constants.credentialSidKey: Constants.expectedCredentialSid],
                                                 Constants.dateCreatedKey: "2020/06/01"]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    let factorPayload = CreateFactorPayload(friendlyName: Constants.friendlyNameValue, type: Constants.pushType, serviceSid: Constants.serviceSidValue,
                                            identity: Constants.identityValue, config: [:], binding: [:], accessToken: Constants.accessToken, metadata: nil)
    XCTAssertThrowsError(try mapper.fromAPI(withData: data, factorPayload: factorPayload)) { error in
      XCTAssertEqual(((error as! TwilioVerifyError).originalError as! MapperError), MapperError.invalidDate)
    }
  }
  
  func testFromStorage_withValidFactorStored_shouldReturnFactor() {
    let expectedFactor = PushFactor(
      status: .verified,
      sid: Constants.expectedSidValue,
      friendlyName: Constants.expectedFriendlyName,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      identity: Constants.identityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid, notificationPlatform: .apn),
      keyPairAlias: Constants.expectedKeyPairAlias)
    var factor: Factor!
    XCTAssertNoThrow(factor = try! mapper.fromStorage(withData: JSONEncoder().encode(expectedFactor)), "Factor mapper should succeed")
    XCTAssertTrue(factor is PushFactor, "Factor should be \(PushFactor.self)")
    XCTAssertEqual(factor.sid, expectedFactor.sid, "Factor sid should be \(expectedFactor.sid) but was \(factor.sid)")
    XCTAssertEqual(factor.serviceSid, expectedFactor.serviceSid, "Factor serviceSid should be \(expectedFactor.serviceSid) but was \(factor.serviceSid)")
    XCTAssertEqual(factor.friendlyName, expectedFactor.friendlyName, "Factor friendlyName should be \(expectedFactor.friendlyName) but was \(factor.friendlyName)")
    XCTAssertEqual(factor.accountSid, expectedFactor.accountSid, "Factor accountSid should be \(expectedFactor.accountSid) but was \(factor.accountSid)")
    XCTAssertEqual(factor.status, expectedFactor.status, "Factor status should be \(expectedFactor.status) but was \(factor.status)")
    XCTAssertEqual(factor.createdAt, expectedFactor.createdAt, "Factor createdAt should be \(expectedFactor.createdAt) but was \(factor.createdAt)")
    XCTAssertEqual((factor as! PushFactor).keyPairAlias, expectedFactor.keyPairAlias,
                   "Factor keyPairAlias should be \(String(describing: expectedFactor.keyPairAlias)) but was \(String(describing: (factor as! PushFactor).keyPairAlias))")
  }
  
  func testFromStorage_withoutNotificationPlatform_shouldReturnFactor() {
    let expectedStoredFactor: [String: Any] = ["sid": Constants.expectedSidValue,
                                               "type": Constants.pushType.rawValue,
                                               "friendlyName": Constants.expectedFriendlyName,
                                               "accountSid": Constants.expectedAccountSid,
                                               "serviceSid": Constants.serviceSidValue,
                                               "identity": Constants.identityValue,
                                               "status": FactorStatus.verified.rawValue,
                                               "config": ["credentialSid": Constants.expectedCredentialSid],
                                               "createdAt": Date().timeIntervalSince1970,
                                               "keyPairAlias": Constants.expectedKeyPairAlias]
    let data = try! JSONSerialization.data(withJSONObject: expectedStoredFactor, options: .prettyPrinted)
    var factor: Factor!
    XCTAssertNoThrow(factor = try! mapper.fromStorage(withData: data), "Factor mapper should succeed")
    XCTAssertTrue(factor is PushFactor, "Factor should be \(PushFactor.self)")
    XCTAssertEqual((factor as! PushFactor).config.notificationPlatform, NotificationPlatform.apn,
                   "Factor notification platform should be \(NotificationPlatform.apn) but was \((factor as! PushFactor).config.notificationPlatform)")
  }
  
  func testFromStorage_withInvalidFactorStored_shouldThrow() {
    let expectedFactorResponse = [Constants.sidKey: Constants.expectedSidValue,
                                  Constants.friendlyNameKey: Constants.expectedFriendlyName,
                                  Constants.accountSidKey: Constants.expectedAccountSid,
                                  Constants.statusKey: FactorStatus.unverified.rawValue,
                                  Constants.typeKey: Constants.pushType.rawValue]
    let data = try! JSONSerialization.data(withJSONObject: expectedFactorResponse, options: .prettyPrinted)
    XCTAssertThrowsError(try mapper.fromStorage(withData: data)) { error in
      XCTAssertTrue(error is DecodingError)
    }
  }
  
  func testFromStorage_withInvalidFactorTypeStored_shouldThrow() {
    let factor = [Constants.sidKey: Constants.expectedSidValue,
                  Constants.friendlyNameKey: Constants.expectedFriendlyName,
                  Constants.accountSidKey: Constants.expectedAccountSid,
                  Constants.statusKey: FactorStatus.unverified.rawValue,
                  Constants.typeKey: "weird"]
    let data = try! JSONSerialization.data(withJSONObject: factor, options: .prettyPrinted)
    XCTAssertThrowsError(try mapper.fromStorage(withData: data)) { error in
      XCTAssertTrue(error as! MapperError == MapperError.invalidArgument)
    }
  }
  
  func testMapToData_shouldReturnFactorAsData() {
    let expectedFactor = PushFactor(
      status: .unverified,
      sid: Constants.expectedSidValue,
      friendlyName: Constants.expectedFriendlyName,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      identity: Constants.identityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid, notificationPlatform: .apn),
      keyPairAlias: Constants.expectedKeyPairAlias)
    var factorData: Data!
    XCTAssertNoThrow(factorData = try! mapper.toData(expectedFactor), "Factor mapper should succeed")
    let factor = try! JSONDecoder().decode(PushFactor.self, from: factorData)
    XCTAssertEqual(factor.sid, expectedFactor.sid, "Factor sid should be \(expectedFactor.sid) but was \(factor.sid)")
    XCTAssertEqual(factor.serviceSid, expectedFactor.serviceSid, "Factor serviceSid should be \(expectedFactor.serviceSid) but was \(factor.serviceSid)")
    XCTAssertEqual(factor.friendlyName, expectedFactor.friendlyName, "Factor friendlyName should be \(expectedFactor.friendlyName) but was \(factor.friendlyName)")
    XCTAssertEqual(factor.accountSid, expectedFactor.accountSid, "Factor accountSid should be \(expectedFactor.accountSid) but was \(factor.accountSid)")
    XCTAssertEqual(factor.status, expectedFactor.status, "Factor status should be \(expectedFactor.status) but was \(factor.status)")
    XCTAssertEqual(factor.createdAt, expectedFactor.createdAt, "Factor createdAt should be \(expectedFactor.createdAt) but was \(factor.createdAt)")
    XCTAssertEqual(factor.keyPairAlias, expectedFactor.keyPairAlias,
                   "Factor keyPairAlias should be \(String(describing: expectedFactor.keyPairAlias)) but was \(String(describing: factor.keyPairAlias))")
    XCTAssertEqual(factor.config.notificationPlatform, expectedFactor.config.notificationPlatform,
                   "Factor notification platform should be \(expectedFactor.config.notificationPlatform) but was \(factor.config.notificationPlatform)")
  }
  
  func testMapStatus_withValidResponse_shouldReturnFactorStatus() {
    let expectedFactorStatus = FactorStatus.verified
    let response = [Constants.statusKey: expectedFactorStatus.rawValue]
    let responseData = try! JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
    var status: FactorStatus!
    XCTAssertNoThrow(status = try mapper.status(fromData: responseData), "Factor mapper should succeed")
    XCTAssertEqual(status, expectedFactorStatus, "Status should be \(expectedFactorStatus) but was \(status!)")
  }
  
  func testMapStatus_withInvalidResponse_shouldThrow() {
    let response = [Constants.sidKey: Constants.expectedSidValue]
    let responseData = try! JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
    XCTAssertThrowsError(try mapper.status(fromData: responseData)) { error in
      XCTAssertTrue(error as! MapperError == MapperError.invalidArgument)
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
    static let notificationPlatformKey = "notification_platform"
    static let metadataKey = "metadata"
    static let typeKey = "type"
    static let pushType = FactorType.push
    static let friendlyNameValue = "factor name"
    static let serviceSidValue = "serviceSid123"
    static let identityValue = "identity123"
    static let accessToken = "accessToken"
    static let expectedSidValue = "sid123"
    static let expectedFriendlyName = "push_factor"
    static let expectedAccountSid = "accountSid123"
    static let expectedCredentialSid = "credentialSid123"
    static let expectedKeyPairAlias = "alias"
    static let expectedDate = "2020-06-05T15:57:47Z"
    static let expectedNotificationPlatform = "none"
    static let expectedMetadata = ["os": "iOS", "device": "iPhone"]
  }
}
