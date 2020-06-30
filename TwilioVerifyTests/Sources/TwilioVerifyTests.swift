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
    twilioVerify = TwilioVerifyBuilder().setURL("https://twilio.com").setNetworkProvider(networkProvider).build()
  }
  
  func testCreateFactor_shouldSucceed() {
    createFactor()
  }
  
  func testVerifyFactor_shouldSucceed() {
    createFactor()
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse: [String: Any] = [Constants.sidKey: Constants.sidValue,
                                           Constants.statusKey: FactorStatus.verified.rawValue]
    let data = try! JSONSerialization.data(withJSONObject: expectedResponse, options: .prettyPrinted)
    networkProvider.response = Response(data: data, headers: [:])
    let factorPayload = VerifyPushFactorPayload(sid: Constants.sidValue)
    var pushFactor: PushFactor!
    twilioVerify.verifyFactor(withPayload: factorPayload, success: { factor in
      pushFactor = factor as? PushFactor
      successExpectation.fulfill()
    }) { error in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertEqual(pushFactor.sid, expectedResponse[Constants.sidKey] as! String,
                   "Sid should be \(expectedResponse[Constants.sidKey] as! String) but was \(pushFactor.sid)")
    XCTAssertEqual(pushFactor.status, FactorStatus(rawValue: expectedResponse[Constants.statusKey] as! String),
                   "Factor status should be \(FactorStatus(rawValue: expectedResponse[Constants.statusKey] as! String)!) but was \(pushFactor.status)")
  }
  
  func createFactor() {
    let successExpectation = expectation(description: "Wait for success response")
    let expectedResponse: [String: Any] = [Constants.sidKey: Constants.sidValue,
                                           Constants.friendlyNameKey: Constants.friendlyNameValue,
                                           Constants.accountSidKey: Constants.accountSidValue,
                                           Constants.statusKey: Constants.statusValue,
                                           Constants.configKey: [Constants.credentialSidKey: Constants.credentialSidValue],
                                           Constants.dateCreatedKey: Constants.dateCreatedValue]
    let data = try! JSONSerialization.data(withJSONObject: expectedResponse, options: .prettyPrinted)
    networkProvider.response = Response(data: data, headers: [:])
    let jwe = """
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
      enrollmentJwe: jwe)
    var pushFactor: PushFactor!
    twilioVerify.createFactor(withPayload: factorPayload, success: { factor in
      pushFactor = factor as? PushFactor
      successExpectation.fulfill()
    }) { error in
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
    static let sidValue = "sid123"
    static let friendlyNameKey = "friendly_name"
    static let friendlyNameValue = "friendlyName"
    static let accountSidKey = "account_sid"
    static let accountSidValue = "accountSid123"
    static let statusKey = "status"
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
    static let enrollmentJWE = "jwe"
    static let expectedFactor = PushFactor(
      sid: "sid",
      friendlyName: "friendlyName",
      accountSid: "accountSid",
      serviceSid: "serviceSid",
      entityIdentity: "entityIdentity",
      createdAt: Date(),
      config: Config(credentialSid: "credentialSid"))
  }
}
