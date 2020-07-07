//
//  FactorRepositoryTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/9/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class FactorRepositoryTests: XCTestCase {
  
  private var factorAPIClient: FactorAPIClientMock!
  private var storage: StorageProviderMock!
  private var factorMapper: FactorMapperMock!
  private var factorRepository: FactorRepository!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    factorAPIClient = FactorAPIClientMock()
    storage = StorageProviderMock()
    factorMapper = FactorMapperMock()
    factorRepository = FactorRepository(apiClient: factorAPIClient, storage: storage, factorMapper: factorMapper)
  }
  
  func testCreateFactor_withValidResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let factorPayload = CreateFactorPayload(
      friendlyName: Constants.friendlyNameValue,
      type: Constants.pushType,
      serviceSid: Constants.serviceSidValue,
      entity: Constants.entityIdentityValue,
      config: [:], binding: [:],
      jwe: Constants.jweValue)
    let factorData = try! JSONEncoder().encode(Constants.factor)
    factorAPIClient.factorData = factorData
    factorMapper.expectedFactor = Constants.factor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    storage.expectedSid = Constants.factor.sid
    storage.factorData = factorData
    var factorResponse: Factor?
    factorRepository.create(withPayload: factorPayload, success: { factor in
      factorResponse = factor as? PushFactor
      successExpectation.fulfill()
    }) { error in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertTrue(factorResponse is PushFactor, "Factor should be \(PushFactor.self)")
    XCTAssertEqual(factorResponse?.sid, Constants.factor.sid, "Factor sid should be \(Constants.factor.sid) but was \(factorResponse!.sid)")
    XCTAssertEqual(factorResponse?.accountSid, Constants.factor.accountSid, "Factor accountSid should be \(Constants.factor.accountSid) but was \(factorResponse!.accountSid)")
    XCTAssertEqual(factorResponse?.createdAt, Constants.factor.createdAt, "Factor createdAt should be \(Constants.factor.createdAt) but was \(factorResponse!.createdAt)")
    XCTAssertEqual(factorResponse?.entityIdentity, Constants.factor.entityIdentity, "Factor entityIdentity should be \(Constants.factor.entityIdentity) but was \(factorResponse!.entityIdentity)")
    XCTAssertEqual(factorResponse?.friendlyName, Constants.factor.friendlyName, "Factor friendlyName should be \(Constants.factor.friendlyName) but was \(factorResponse!.friendlyName)")
    XCTAssertEqual(factorResponse?.serviceSid, Constants.factor.serviceSid, "Factor serviceSid should be \(Constants.factor.serviceSid) but was \(factorResponse!.serviceSid)")
    XCTAssertEqual(factorResponse?.status, Constants.factor.status, "Factor status should be \(Constants.factor.status) but was \(factorResponse!.status)")
    XCTAssertEqual((factorResponse as! PushFactor).config.credentialSid, Constants.factor.config.credentialSid, "Factor credentialSid should be \(Constants.factor.config.credentialSid) but was \((factorResponse as! PushFactor).config.credentialSid)")
  }
  
  func testCreateFactor_withInvalidResponse_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let factorPayload = CreateFactorPayload(
      friendlyName: Constants.friendlyNameValue,
      type: Constants.pushType,
      serviceSid: Constants.serviceSidValue,
      entity: Constants.entityIdentityValue,
      config: [:], binding: [:],
      jwe: Constants.jweValue)
    let expectedError = NetworkError.invalidData
    factorAPIClient.error = expectedError
    factorRepository.create(withPayload: factorPayload, success: { factor in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual((error as! NetworkError).errorDescription, expectedError.errorDescription)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testCreateFactor_withErrorInMapper_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let factorPayload = CreateFactorPayload(
      friendlyName: Constants.friendlyNameValue,
      type: Constants.pushType,
      serviceSid: Constants.serviceSidValue,
      entity: Constants.entityIdentityValue,
      config: [:], binding: [:],
      jwe: Constants.jweValue)
    let factorData = try! JSONEncoder().encode(Constants.factor)
    factorAPIClient.factorData = factorData
    let expectedError = MapperError.invalidArgument
    factorMapper.error = expectedError
    factorRepository.create(withPayload: factorPayload, success: { factor in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual((error as! MapperError), expectedError)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testCreateFactor_withErrorGettingStoredFactor_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let factorPayload = CreateFactorPayload(
      friendlyName: Constants.friendlyNameValue,
      type: Constants.pushType,
      serviceSid: Constants.serviceSidValue,
      entity: Constants.entityIdentityValue,
      config: [:], binding: [:],
      jwe: Constants.jweValue)
    let factorData = try! JSONEncoder().encode(Constants.factor)
    factorAPIClient.factorData = factorData
    factorMapper.expectedFactor = Constants.factor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    let expectedError = TestError.operationFailed
    storage.errorGetting = expectedError
    storage.expectedSid = Constants.factor.sid
    factorRepository.create(withPayload: factorPayload, success: { factor in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual((error as! TestError), expectedError)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testCreateFactor_withErrorSavingFactor_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let factorPayload = CreateFactorPayload(
      friendlyName: Constants.friendlyNameValue,
      type: Constants.pushType,
      serviceSid: Constants.serviceSidValue,
      entity: Constants.entityIdentityValue,
      config: [:], binding: [:],
      jwe: Constants.jweValue)
    let factorData = try! JSONEncoder().encode(Constants.factor)
    factorAPIClient.factorData = factorData
    factorMapper.expectedFactor = Constants.factor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    let expectedError = TestError.operationFailed
    storage.errorSaving = expectedError
    storage.expectedSid = Constants.factor.sid
    factorRepository.create(withPayload: factorPayload, success: { factor in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual((error as! TestError), expectedError)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testVerifyFactor_withValidResponse_shouldSucceed() {
    let successExpectation = expectation(description: "Wait for success response")
    let payload = "authPayload"
    let expectedFactorStatus = FactorStatus.verified
    let response: [String: Any] = [Constants.sidKey: Constants.expectedSidValue,
                                   Constants.friendlyNameKey: Constants.friendlyNameValue,
                                   Constants.accountSidKey: Constants.expectedAccountSid,
                                   Constants.serviceSidKey: Constants.serviceSidValue,
                                   Constants.statusKey: expectedFactorStatus.rawValue]
    let responseData = try! JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
    factorAPIClient.expectedFactorSid = Constants.factor.sid
    factorAPIClient.statusData = responseData
    storage.expectedSid = Constants.factor.sid
    storage.factorData = responseData
    let expectedFactor = PushFactor(
      status: expectedFactorStatus,
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let expectedFactorData = try! JSONEncoder().encode(expectedFactor)
    factorMapper.expectedFactor = Constants.factor
    factorMapper.expectedData = expectedFactorData
    factorMapper.expectedStatusData = responseData
    
    var factorResponse: Factor?
    factorRepository.verify(Constants.factor, payload: payload, success: { factor in
      factorResponse = factor
      successExpectation.fulfill()
    }) { error in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertTrue(factorResponse is PushFactor, "Factor should be \(PushFactor.self)")
    XCTAssertEqual(factorResponse?.status, expectedFactorStatus)
  }
  
  func testVerifyFactor_withInvalidResponse_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let expectedError = NetworkError.invalidData
    factorAPIClient.error = expectedError
    var error: Error!
    factorRepository.verify(Constants.factor, payload: "", success: { factor in
      XCTFail()
      failureExpectation.fulfill()
    }) { failureError in
      error = failureError
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual((error as! NetworkError).errorDescription, expectedError.errorDescription)
  }
  
  func testVerifyFactor_withErrorInMaper_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let payload = "authPayload"
    let response: [String: Any] = [Constants.sidKey: Constants.expectedSidValue]
    let responseData = try! JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
    factorAPIClient.expectedFactorSid = Constants.factor.sid
    factorAPIClient.statusData = responseData
    factorMapper.expectedStatusData = responseData
    var error: Error!
    factorRepository.verify(Constants.factor, payload: payload, success: { factor in
      XCTFail()
      failureExpectation.fulfill()
    }) { failureError in
      error = failureError
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual((error as! MapperError).errorDescription, MapperError.invalidArgument.errorDescription,
                   "Error description should be \(MapperError.invalidArgument.errorDescription) but was \((error as! MapperError).errorDescription)")
  }
  
  func testSaveFactor_withFactorSuccessfullyStored_shouldSucceed() {
    let factorData = try! JSONEncoder().encode(Constants.factor)
    storage.expectedSid = Constants.factor.sid
    storage.factorData = factorData
    factorMapper.expectedFactor = Constants.factor
    factorMapper.expectedData = factorData
    XCTAssertNoThrow(try factorRepository.save(Constants.factor), "Save factor shouldn't throw")
  }
  
  func testSaveFactor_withStorageError_shouldFail() {
    factorMapper.expectedFactor = Constants.factor
    let expectedError = TestError.operationFailed
    storage.expectedSid = Constants.factor.sid
    storage.errorSaving = expectedError
    XCTAssertThrowsError(try factorRepository.save(Constants.factor), "Save factor should throw") { error in
      XCTAssertEqual((error as! TestError), expectedError)
    }
  }
  
  func testSaveFactor_withMapperError_shouldFail() {
    let expectedError = MapperError.invalidArgument
    factorMapper.expectedFactor = Constants.factor
    factorMapper.error = expectedError
    storage.expectedSid = Constants.factor.sid
    XCTAssertThrowsError(try factorRepository.save(Constants.factor), "Save factor should throw") { error in
      XCTAssertEqual((error as! MapperError), expectedError)
    }
  }
  
  func testGetFactor_withStoredFactor_shouldSucceed() {
    let factorData = try! JSONEncoder().encode(Constants.factor)
    storage.expectedSid = Constants.factor.sid
    storage.factorData = factorData
    factorMapper.expectedData = factorData
    XCTAssertNoThrow(try factorRepository.get(withSid: Constants.factor.sid), "Get factor shouldn't throw")
  }
  
  func testGetFactor_withStorageError_shouldFail() {
    let expectedError = TestError.operationFailed
    storage.expectedSid = Constants.factor.sid
    storage.errorGetting = expectedError
    XCTAssertThrowsError(try factorRepository.get(withSid: Constants.factor.sid), "Get factor should throw") { error in
      XCTAssertEqual((error as! TestError), expectedError)
    }
  }
  
  func testGetFactor_withMapperError_shouldFail() {
    let factorData = try! JSONEncoder().encode(Constants.factor)
    let expectedError = MapperError.invalidArgument
    storage.expectedSid = Constants.factor.sid
    storage.factorData = factorData
    factorMapper.error = expectedError
    XCTAssertThrowsError(try factorRepository.get(withSid: Constants.factor.sid), "Get factor should throw") { error in
      XCTAssertEqual((error as! MapperError), expectedError)
    }
  }
  
  func testDeleteFactor_withSuccessResponse_shouldDeleteFactorStored() {
    let expectation = self.expectation(description: "testDeleteFactor_withSuccessResponse_shouldDeleteFactorStored")
    factorRepository.delete(Constants.factor, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(storage.removedKey, Constants.factor.sid,
                   "Key to be removed should be \(Constants.factor.sid) but was \(storage.removedKey!)")
  }
  
  func testDeleteFactor_withErrorResponse_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withErrorResponse_shouldFail")
    let expectedError = TestError.operationFailed
    factorAPIClient.error = expectedError
    var error: Error!
    factorRepository.delete(Constants.factor, success: {
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertNil(storage.removedKey, "Storage shouldn't be called")
    XCTAssertEqual((error as! TestError), TestError.operationFailed,
                   "Error should be \(TestError.operationFailed) but was \(error!)")
  }
  
  func testDeleteFactor_withErrorDeletingFactor_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withErrorDeletingFactor_shouldFail")
    let expectedError = TestError.operationFailed
    storage.errorRemoving = expectedError
    storage.expectedSid = Constants.factor.sid
    var error: Error!
    factorRepository.delete(Constants.factor, success: {
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertNil(storage.removedKey, "Storage shouldn't be called")
    XCTAssertEqual((error as! TestError), TestError.operationFailed,
                   "Error should be \(TestError.operationFailed) but was \(error!)")
  }
}

private extension FactorRepositoryTests {
  struct Constants {
    static let pushType = FactorType.push
    static let sidKey = "sid"
    static let friendlyNameKey = "friendlyName"
    static let accountSidKey = "account_sid"
    static let statusKey = "status"
    static let serviceSidKey = "service_sid"
    static let friendlyNameValue = "factor name"
    static let serviceSidValue = "serviceSid123"
    static let entityIdentityValue = "entityId123"
    static let jweValue = "jwe"
    static let expectedSidValue = "sid123"
    static let expectedAccountSid = "accountSid123"
    static let expectedCredentialSid = "credentialSid123"
    static let factor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
  }
}
