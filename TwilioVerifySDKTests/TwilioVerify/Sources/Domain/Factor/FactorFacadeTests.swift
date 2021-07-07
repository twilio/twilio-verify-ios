//
//  FactorFacadeTests.swift
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

// swiftlint:disable force_cast type_body_length file_length
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
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput(field: "invalid payload") as NSError)
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
    XCTAssertTrue(factor is PushFactor, "Factor should be a PushFactor")
    let pushFactor = factor as! PushFactor
    XCTAssertEqual(pushFactor.sid, Constants.factor.sid,
                   "Factor Sid should be \(Constants.factor.sid) but was \(pushFactor.sid)")
    XCTAssertEqual(pushFactor.friendlyName, Constants.factor.friendlyName,
                   "Friendly name should be \(Constants.factor.friendlyName) but was \(pushFactor.friendlyName)")
    XCTAssertEqual(pushFactor.accountSid, Constants.factor.accountSid,
                   "Accound sid should be \(Constants.factor.accountSid) but was \(pushFactor.accountSid)")
    XCTAssertEqual(pushFactor.serviceSid, Constants.factor.serviceSid,
                   "Service Sid should be \(Constants.factor.serviceSid) but was \(pushFactor.serviceSid)")
    XCTAssertEqual(pushFactor.identity, Constants.factor.identity,
                   "Identity should be \(Constants.factor.identity) but was \(pushFactor.identity)")
    XCTAssertEqual(pushFactor.createdAt, Constants.factor.createdAt,
                   "Creation date should be \(Constants.factor.createdAt) but was \(pushFactor.createdAt)")
    XCTAssertEqual(pushFactor.config.credentialSid, Constants.factor.config.credentialSid,
                   "Credential Sid should be \(Constants.factor.config.credentialSid) but was \(pushFactor.config.credentialSid)")
  }
  
  func testVerifyFactor_withInvalidInput_shouldFail() {
    let expectation = self.expectation(description: "testVerifyFactor_withInvalidInput_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput(field: "field") as NSError)
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
    XCTAssertTrue(factor is PushFactor, "Factor should be a PushFactor")
    let pushFactor = factor as! PushFactor
    XCTAssertEqual(pushFactor.sid, Constants.factor.sid,
                   "Factor Sid should be \(Constants.factor.sid) but was \(pushFactor.sid)")
    XCTAssertEqual(pushFactor.friendlyName, Constants.factor.friendlyName,
                   "Friendly name should be \(Constants.factor.friendlyName) but was \(pushFactor.friendlyName)")
    XCTAssertEqual(pushFactor.accountSid, Constants.factor.accountSid,
                   "Accound sid should be \(Constants.factor.accountSid) but was \(pushFactor.accountSid)")
    XCTAssertEqual(pushFactor.serviceSid, Constants.factor.serviceSid,
                   "Service Sid should be \(Constants.factor.serviceSid) but was \(pushFactor.serviceSid)")
    XCTAssertEqual(pushFactor.identity, Constants.factor.identity,
                   "Identity should be \(Constants.factor.identity) but was \(pushFactor.identity)")
    XCTAssertEqual(pushFactor.createdAt, Constants.factor.createdAt,
                   "Creation date should be \(Constants.factor.createdAt) but was \(pushFactor.createdAt)")
    XCTAssertEqual(pushFactor.config.credentialSid, Constants.factor.config.credentialSid,
                   "Credential Sid should be \(Constants.factor.config.credentialSid) but was \(pushFactor.config.credentialSid)")
  }
  
  func testUpdateFactor_withValidInput_shouldSucceed() {
    let expectation = self.expectation(description: "testUpdateFactor_withValidInput_shouldSucceed")
    factory.factor = Constants.factor
    var factor: Factor!
    facade.updateFactor(withPayload: Constants.updateFactorPayload, success: { response in
      factor = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(factor is PushFactor, "Factor should be a PushFactor")
    let pushFactor = factor as! PushFactor
    XCTAssertEqual(pushFactor.sid, Constants.factor.sid,
                   "Factor Sid should be \(Constants.factor.sid) but was \(pushFactor.sid)")
    XCTAssertEqual(pushFactor.friendlyName, Constants.factor.friendlyName,
                   "Friendly name should be \(Constants.factor.friendlyName) but was \(pushFactor.friendlyName)")
    XCTAssertEqual(pushFactor.accountSid, Constants.factor.accountSid,
                   "Accound sid should be \(Constants.factor.accountSid) but was \(pushFactor.accountSid)")
    XCTAssertEqual(pushFactor.serviceSid, Constants.factor.serviceSid,
                   "Service Sid should be \(Constants.factor.serviceSid) but was \(pushFactor.serviceSid)")
    XCTAssertEqual(pushFactor.identity, Constants.factor.identity,
                   "Identity should be \(Constants.factor.identity) but was \(pushFactor.identity)")
    XCTAssertEqual(pushFactor.createdAt, Constants.factor.createdAt,
                   "Creation date should be \(Constants.factor.createdAt) but was \(pushFactor.createdAt)")
    XCTAssertEqual(pushFactor.config.credentialSid, Constants.factor.config.credentialSid,
                   "Credential Sid should be \(Constants.factor.config.credentialSid) but was \(pushFactor.config.credentialSid)")
  }
  
  func testUpdateFactor_withInvalidInput_shouldFail() {
    let expectation = self.expectation(description: "testUpdateFactor_withInvalidInput_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: InputError.invalidInput(field: "field") as NSError)
    var error: TwilioVerifyError!
    let fakePayload = FakeUpdateFactorPayload(sid: Constants.serviceSid)
    
    facade.updateFactor(withPayload: fakePayload, success: { _ in
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
  
  func testUpdateFactor_withValidInputAndErrorVerifyingFactor_shouldFail() {
    let expectation = self.expectation(description: "testUpdateFactor_withValidInputAndErrorVerifyingFactor_shouldFail")
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    factory.error = expectedError
    
    facade.updateFactor(withPayload: Constants.updateFactorPayload, success: { _ in
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
    XCTAssertTrue(factor is PushFactor, "Factor should be a PushFactor")
    let pushFactor = factor as! PushFactor
    XCTAssertEqual(pushFactor.sid, Constants.factor.sid,
                   "Factor Sid should be \(Constants.factor.sid) but was \(pushFactor.sid)")
    XCTAssertEqual(pushFactor.friendlyName, Constants.factor.friendlyName,
                   "Friendly name should be \(Constants.factor.friendlyName) but was \(pushFactor.friendlyName)")
    XCTAssertEqual(pushFactor.accountSid, Constants.factor.accountSid,
                   "Accound sid should be \(Constants.factor.accountSid) but was \(pushFactor.accountSid)")
    XCTAssertEqual(pushFactor.serviceSid, Constants.factor.serviceSid,
                   "Service Sid should be \(Constants.factor.serviceSid) but was \(pushFactor.serviceSid)")
    XCTAssertEqual(pushFactor.identity, Constants.factor.identity,
                   "Identity should be \(Constants.factor.identity) but was \(pushFactor.identity)")
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
  
  func testGetAll_withSuccessResponse_shouldSucced() {
    let expectation = self.expectation(description: "testGetAll_withSuccessResponse_shouldSucced")
    let factor = Constants.factor
    repository.factors = [factor]
    var factors: [Factor]!
    facade.getAll(success: { factorList in
      factors = factorList
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(factors.first?.sid, factor.sid, "Factor should be \(factor) but was \(factors.first!)")
  }
  
  func testGetAll_withError_shouldFail() {
    let expectation = self.expectation(description: "testGetAll_withError_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: TestError.operationFailed as NSError)
    repository.error = TestError.operationFailed
    var error: TwilioVerifyError!
    facade.getAll(success: { _ in
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
  
  func testClearLocalStorage_withErrorDeletingFactors_shouldCallRepositoryClearLocalStorage() {
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    let expectedCallsToClearLocalStorage = 1
    factory.error = expectedError
    XCTAssertNoThrow(try facade.clearLocalStorage(), "Clear local storage not should throw")
    XCTAssertEqual(repository.callsToClearStorage, expectedCallsToClearLocalStorage)
  }
  
  func testClearLocalStorage_withErrorDeletintFactorsAndErrorClearingStorage_shouldThrow() {
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    let expectedCallsToClearLocalStorage = 1
    factory.error = expectedError
    repository.error = expectedError
    XCTAssertThrowsError(try facade.clearLocalStorage(), "Clear should throw") { error in
      let error = error as! TwilioVerifyError
      XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                     "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
      XCTAssertEqual(error.originalError, expectedError.originalError,
                     "Original error should be \(expectedError.originalError) but was \(error.originalError)")
      XCTAssertEqual(repository.callsToClearStorage, expectedCallsToClearLocalStorage)
    }
  }
  
  func testClearLocalStorage_withoutErrorDeletingFactors_shouldNotCallRepositoryClearLocalStorage() {
    let expectedCallsToClearLocalStorage = 0
    XCTAssertNoThrow(try facade.clearLocalStorage(), "Clear local storage not should throw")
    XCTAssertEqual(repository.callsToClearStorage, expectedCallsToClearLocalStorage)
  }
}

private extension FactorFacadeTests {
  struct Constants {
    static let accessToken = "accessToken"
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
      accessToken: Constants.accessToken
    )
    static let factor = PushFactor(
      sid: "sid",
      friendlyName: Constants.friendlyName,
      accountSid: "accountSid",
      serviceSid: Constants.serviceSid,
      identity: Constants.identity,
      createdAt: Date(),
      config: Constants.config
    )
    static let updateFactorPayload = UpdatePushFactorPayload(
      sid: Constants.factor.sid,
      pushToken: Constants.pushToken)
    static let verifyFactorPayload = VerifyPushFactorPayload(sid: "sid")
  }
}
