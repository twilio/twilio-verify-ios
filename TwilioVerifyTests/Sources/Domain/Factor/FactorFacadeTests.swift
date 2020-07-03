//
//  FactorFacadeTests.swift
//  TwilioVerifyTests
//
//  Created by Santiago Avila on 6/12/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class FactorFacadeTests: XCTestCase {

  var factory: PushFactoryMock!
  var repository: FactorRepositoryMock!
  var facade: FactorFacadeProtocol!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    factory = PushFactoryMock()
    repository = FactorRepositoryMock()
    facade = FactorFacade(factory: factory, repository: repository)
  }
  
  func testCreateFactor_withInvalidInput_shouldFail() {
    let expectation = self.expectation(description: "testCreateFactor_withInvalidInput_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput as NSError)
    var error: TwilioVerifyError!
    let fakePayload = FakeFactorPayload(
      friendlyName: Constants.friendlyName,
      serviceSid: Constants.serviceSid,
      identity: Constants.identity,
      factorType: FactorType.push
    )
    
    facade.createFactor(withPayload: fakePayload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { result in
      error = result
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testCreateFactor_withValidInputAndErrorCreatingFactor_shouldFail() {
    let expectation = self.expectation(description: "testCreateFactor_withInvalidInput_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    factory.error = expectedError
    
    facade.createFactor(withPayload: Constants.factorPayload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { result in
      error = result
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testCreateFactor_withValidInput_shouldSucceed() {
    let expectation = self.expectation(description: "testCreateFactor_withValidInput_shouldSucceed")
    var factor: Factor!
    factory.factor = Constants.factor
    
    facade.createFactor(withPayload: Constants.factorPayload, success: { result in
      factor = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(factor is PushFactor,  "Factor should be a PushFactor")
    let pushFactor = factor as! PushFactor
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
  
  func testVerifyFactor_withInvalidInput_shouldFail() {
    let expectation = self.expectation(description: "testVerifyFactor_withInvalidInput_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput as NSError)
    var error: TwilioVerifyError!
    let fakePayload = FakeVerifyPushFactorPayload(sid: Constants.serviceSid)
    
    facade.verifyFactor(withPayload: fakePayload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { result in
      error = result
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testVerifyFactor_withValidInputAndErrorVerifyingFactor_shouldFail() {
    let expectation = self.expectation(description: "testCreateFactor_withInvalidInput_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    factory.error = expectedError
    
    facade.verifyFactor(withPayload: Constants.verifyFactorPayload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { result in
      error = result
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testVerifyFactor_withValidInput_shouldSucceed() {
    let expectation = self.expectation(description: "testCreateFactor_withValidInput_shouldSucceed")
    var factor: Factor!
    factory.factor = Constants.factor
    
    facade.verifyFactor(withPayload: Constants.verifyFactorPayload, success: { result in
      factor = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(factor is PushFactor,  "Factor should be a PushFactor")
    let pushFactor = factor as! PushFactor
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
  
  func testGet_factorNotStored_shouldFail() {
    let expectation = self.expectation(description: "testGet_factorNotStored_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: StorageError.error("Factor not found") as NSError)
    var error: TwilioVerifyError!
    repository.error = TestError.operationFailed
    
    facade.get(withSid: "sid", success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { failureReson in
      error = failureReson
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
  
  func testGet_factorExists_shouldSucceed() {
    let expectation = self.expectation(description: "testGet_factorExists_shouldSucceed")
    var factor: Factor!
    repository.factor = Constants.factor
    
    facade.get(withSid: "sid", success: { result in
      factor = result
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(factor is PushFactor,  "Factor should be a PushFactor")
    let pushFactor = factor as! PushFactor
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
  
  func testDelete_withSuccessResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testDelete_withSuccessResponse_shouldSucceed")
    facade.delete(withSid: "sid", success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(factory.deleteFactorCalled, "Delete factor should be called")
  }
  
  func testDelete_withErrorResponse_shouldFail() {
    let expectation = self.expectation(description: "testDelete_withErrorResponse_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: StorageError.error("Factor not found") as NSError)
    factory.error = expectedError
    var error: TwilioVerifyError!
    facade.delete(withSid: "sid", success: {
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
    XCTAssertEqual(error.originalError, expectedError.originalError,
                   "Original error should be \(expectedError.originalError) but was \(error.originalError)")
  }
}

private extension FactorFacadeTests {
  struct Constants {
    static let jwe = "jwe"
    static let friendlyName = "friendlyName"
    static let pushToken = "pushToken"
    static let serviceSid = "serviceSid"
    static let identity = "identity"
    static let data = "data"
    static let config = Config(credentialSid: "credentialSid")
    static let factorPayload = PushFactorPayload(
      friendlyName: Constants.friendlyName,
      serviceSid: Constants.serviceSid,
      identity: Constants.identity,
      pushToken: Constants.pushToken,
      enrollmentJwe: Constants.jwe
    )
    static let factor = PushFactor(
      sid: "sid",
      friendlyName: Constants.friendlyName,
      accountSid: "accountSid",
      serviceSid: Constants.serviceSid,
      entityIdentity: Constants.identity,
      createdAt: Date(),
      config: Constants.config
    )
    static let verifyFactorPayload = VerifyPushFactorPayload(sid: "sid")
  }
}
