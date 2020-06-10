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
    factorAPIClient = FactorAPIClientMock(authentication: AuthenticationMock(), baseURL: Constants.baseURL)
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
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
    factorAPIClient.factor = factorData
    factorMapper.expectedFactor = expectedFactor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    storage.expectedSid = expectedFactor.sid
    storage.factorData = factorData
    factorRepository.create(createFactorPayload: factorPayload, success: { factor in
      XCTAssertTrue(factor is PushFactor, "Factor should be \(PushFactor.self)")
      XCTAssertEqual(factor.sid, expectedFactor.sid, "Factor sid should be \(expectedFactor.sid) but was \(factor.sid)")
      XCTAssertEqual(factor.accountSid, expectedFactor.accountSid, "Factor accountSid should be \(expectedFactor.accountSid) but was \(factor.accountSid)")
      XCTAssertEqual(factor.createdAt, expectedFactor.createdAt, "Factor createdAt should be \(expectedFactor.createdAt) but was \(factor.createdAt)")
      XCTAssertEqual(factor.entityIdentity, expectedFactor.entityIdentity, "Factor entityIdentity should be \(expectedFactor.entityIdentity) but was \(factor.entityIdentity)")
      XCTAssertEqual(factor.friendlyName, expectedFactor.friendlyName, "Factor friendlyName should be \(expectedFactor.friendlyName) but was \(factor.friendlyName)")
      XCTAssertEqual(factor.serviceSid, expectedFactor.serviceSid, "Factor serviceSid should be \(expectedFactor.serviceSid) but was \(factor.serviceSid)")
      XCTAssertEqual(factor.status, expectedFactor.status, "Factor status should be \(expectedFactor.status) but was \(factor.status)")
      XCTAssertEqual((factor as! PushFactor).config.credentialSid, expectedFactor.config.credentialSid, "Factor credentialSid should be \(expectedFactor.config.credentialSid) but was \((factor as! PushFactor).config.credentialSid)")
      successExpectation.fulfill()
    }) { error in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
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
    factorRepository.create(createFactorPayload: factorPayload, success: { factor in
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
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
    factorAPIClient.factor = factorData
    let expectedError = MapperError.invalidArgument
    factorMapper.error = expectedError
    factorRepository.create(createFactorPayload: factorPayload, success: { factor in
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
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
    factorAPIClient.factor = factorData
    factorMapper.expectedFactor = expectedFactor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    let expectedError = TestError.operationFailed
    storage.errorGetting = expectedError
    storage.expectedSid = expectedFactor.sid
    factorRepository.create(createFactorPayload: factorPayload, success: { factor in
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
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
    factorAPIClient.factor = factorData
    factorMapper.expectedFactor = expectedFactor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    let expectedError = TestError.operationFailed
    storage.errorSaving = expectedError
    storage.expectedSid = expectedFactor.sid
    factorRepository.create(createFactorPayload: factorPayload, success: { factor in
      XCTFail()
      failureExpectation.fulfill()
    }) { error in
      XCTAssertEqual((error as! TestError), expectedError)
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
  }
  
  func testSaveFactor_withFactorSuccessfullyStored_shouldSucceed() {
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
    storage.expectedSid = expectedFactor.sid
    storage.factorData = factorData
    factorMapper.expectedFactor = expectedFactor
    factorMapper.expectedData = factorData
    XCTAssertNoThrow(try factorRepository.save(factor: expectedFactor), "Save factor shouldn't throw")
  }
  
  func testSaveFactor_withStorageError_shouldFail() {
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    factorMapper.expectedFactor = expectedFactor
    let expectedError = TestError.operationFailed
    storage.expectedSid = expectedFactor.sid
    storage.errorSaving = expectedError
    XCTAssertThrowsError(try factorRepository.save(factor: expectedFactor), "Save factor should throw") { error in
      XCTAssertEqual((error as! TestError), expectedError)
    }
  }
  
  func testSaveFactor_withMapperError_shouldFail() {
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let expectedError = MapperError.invalidArgument
    factorMapper.expectedFactor = expectedFactor
    factorMapper.error = expectedError
    storage.expectedSid = expectedFactor.sid
    XCTAssertThrowsError(try factorRepository.save(factor: expectedFactor), "Save factor should throw") { error in
      XCTAssertEqual((error as! MapperError), expectedError)
    }
  }
  
  func testGetFactor_withStoredFactor_shouldSucceed() {
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
    storage.expectedSid = expectedFactor.sid
    storage.factorData = factorData
    factorMapper.expectedData = factorData
    XCTAssertNoThrow(try factorRepository.get(sid: expectedFactor.sid), "Get factor shouldn't throw")
  }
  
  func testGetFactor_withStorageError_shouldFail() {
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let expectedError = TestError.operationFailed
    storage.expectedSid = expectedFactor.sid
    storage.errorGetting = expectedError
    XCTAssertThrowsError(try factorRepository.get(sid: expectedFactor.sid), "Get factor should throw") { error in
      XCTAssertEqual((error as! TestError), expectedError)
    }
  }
  
  func testGetFactor_withMapperError_shouldFail() {
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
    let expectedError = MapperError.invalidArgument
    storage.expectedSid = expectedFactor.sid
    storage.factorData = factorData
    factorMapper.error = expectedError
    XCTAssertThrowsError(try factorRepository.get(sid: expectedFactor.sid), "Get factor should throw") { error in
      XCTAssertEqual((error as! MapperError), expectedError)
    }
  }
}

private extension FactorRepositoryTests {
  struct Constants {
    static let baseURL = "https://twilio.com"
    static let pushType = FactorType.push
    static let friendlyNameValue = "factor name"
    static let serviceSidValue = "serviceSid123"
    static let entityIdentityValue = "entityId123"
    static let jweValue = "jwe"
    static let expectedSidValue = "sid123"
    static let expectedAccountSid = "accountSid123"
    static let expectedCredentialSid = "credentialSid123"
  }
}
