//
//  PushFactoryTests.swift
//  TwilioVerifyTests
//
//  Created by Santiago Avila on 6/11/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class PushFactoryTests: XCTestCase {

  var repository: FactorRepositoryMock!
  var keyStorage: KeyStorageMock!
  var factory: PushFactoryProtocol!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    keyStorage = KeyStorageMock()
    repository = FactorRepositoryMock()
    factory = PushFactory(repository: repository, keyStorage: keyStorage)
  }
  
  func testCreateFactor_withErrorCreatingKey_shouldFail() {
    let expectation = self.expectation(description: "testCreateFactor_withErrorCreatingKey_shouldFail")
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    keyStorage.errorCreatingKey = TestError.operationFailed
    
    factory.createFactor(withJwe: Constants.jwe, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
                         serviceSid: Constants.serviceSid, identity: Constants.identity, success: { _ in
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
  
  func testCreateFactor_withErrorCreatingFactor_shouldFail() {
    let expectation = self.expectation(description: "testCreateFactor_withErrorSavingFactor_shouldFail")
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    keyStorage.createKeyResult = Constants.data
    repository.error = TestError.operationFailed
    
    factory.createFactor(withJwe: Constants.jwe, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
                         serviceSid: Constants.serviceSid, identity: Constants.identity, success: { _ in
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
  
  func testCreateFactor_withErrorDeletingKeyWhenFactorCreationFailed_shouldFail() {
    let expectation = self.expectation(description: "testCreateFactor_withErrorDeletingKeyWhenFactorCreationFailed_shouldFail")
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    keyStorage.createKeyResult = Constants.data
    keyStorage.error = TestError.operationFailed
    repository.error = TestError.operationFailed
    
    factory.createFactor(withJwe: Constants.jwe, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
                         serviceSid: Constants.serviceSid, identity: Constants.identity, success: { _ in
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
  
  func testCreateFactor_withErrorSavingFactor_shouldFail() {
    let expectation = self.expectation(description: "testCreateFactor_withErrorSavingFactor_shouldFail")
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    keyStorage.createKeyResult = Constants.data
    repository.saveError = TestError.operationFailed
    repository.factor = Constants.factor
    
    factory.createFactor(withJwe: Constants.jwe, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
                         serviceSid: Constants.serviceSid, identity: Constants.identity, success: { _ in
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
  
  func testCreateFactor_withoutErrors_shouldSucceed() {
    let expectation = self.expectation(description: "testCreateFactor_withoutErrors_shouldSucceed")
    var pushFactor: PushFactor!
    keyStorage.createKeyResult = Constants.data
    repository.factor = Constants.factor
    
    factory.createFactor(withJwe: Constants.jwe, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
                         serviceSid: Constants.serviceSid, identity: Constants.identity, success: { factor in
                          pushFactor = (factor as! PushFactor)
                          expectation.fulfill()
                        }) { _ in
                          XCTFail()
                          expectation.fulfill()
                        }
    
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(pushFactor.sid, Constants.factor.sid,
                   "Factor Sid should be \(Constants.factor.sid) but was \(pushFactor.sid)")
    XCTAssertEqual(pushFactor.friendlyName, Constants.factor.friendlyName,
                   "Friendly name should be \(Constants.factor.friendlyName) but was \(pushFactor.friendlyName)")
    XCTAssertEqual(pushFactor.accountSid, Constants.factor.accountSid,
                   "Accound sid should be \(Constants.factor.accountSid) but was \(pushFactor.accountSid)")
    XCTAssertEqual(pushFactor.serviceSid, Constants.factor.serviceSid,
                   "Service Sid should be \(Constants.factor.serviceSid) but was \(pushFactor.serviceSid)")
    XCTAssertEqual(pushFactor.entityIdentity, Constants.factor.entityIdentity,
                   "Entity Identity should be \(Constants.factor.entityIdentity) but was \(pushFactor.entityIdentity)")
    XCTAssertEqual(pushFactor.createdAt, Constants.factor.createdAt,
                   "Creation date should be \(Constants.factor.createdAt) but was \(pushFactor.createdAt)")
    XCTAssertEqual(pushFactor.config.credentialSid, Constants.factor.config.credentialSid,
                   "Credential Sid should be \(Constants.factor.config.credentialSid) but was \(pushFactor.config.credentialSid)")
  }
}

private extension PushFactoryTests {
  struct Constants {
    static let jwe = "jwe"
    static let friendlyName = "friendlyName"
    static let pushToken = "pushToken"
    static let serviceSid = "serviceSid"
    static let identity = "identity"
    static let data = "data"
    static let config = Config(credentialSid: "credentialSid")
    static let factor = PushFactor(
      sid: "sid",
      friendlyName: Constants.friendlyName,
      accountSid: "accountSid",
      serviceSid: Constants.serviceSid,
      entityIdentity: Constants.identity,
      createdAt: Date(),
      config: Constants.config
    )
  }
}
