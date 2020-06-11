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
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
    factorAPIClient.factorData = factorData
    factorMapper.expectedFactor = expectedFactor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    storage.expectedSid = expectedFactor.sid
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
    XCTAssertEqual(factorResponse?.sid, expectedFactor.sid, "Factor sid should be \(expectedFactor.sid) but was \(factorResponse!.sid)")
    XCTAssertEqual(factorResponse?.accountSid, expectedFactor.accountSid, "Factor accountSid should be \(expectedFactor.accountSid) but was \(factorResponse!.accountSid)")
    XCTAssertEqual(factorResponse?.createdAt, expectedFactor.createdAt, "Factor createdAt should be \(expectedFactor.createdAt) but was \(factorResponse!.createdAt)")
    XCTAssertEqual(factorResponse?.entityIdentity, expectedFactor.entityIdentity, "Factor entityIdentity should be \(expectedFactor.entityIdentity) but was \(factorResponse!.entityIdentity)")
    XCTAssertEqual(factorResponse?.friendlyName, expectedFactor.friendlyName, "Factor friendlyName should be \(expectedFactor.friendlyName) but was \(factorResponse!.friendlyName)")
    XCTAssertEqual(factorResponse?.serviceSid, expectedFactor.serviceSid, "Factor serviceSid should be \(expectedFactor.serviceSid) but was \(factorResponse!.serviceSid)")
    XCTAssertEqual(factorResponse?.status, expectedFactor.status, "Factor status should be \(expectedFactor.status) but was \(factorResponse!.status)")
    XCTAssertEqual((factorResponse as! PushFactor).config.credentialSid, expectedFactor.config.credentialSid, "Factor credentialSid should be \(expectedFactor.config.credentialSid) but was \((factorResponse as! PushFactor).config.credentialSid)")
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
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
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
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
    factorAPIClient.factorData = factorData
    factorMapper.expectedFactor = expectedFactor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    let expectedError = TestError.operationFailed
    storage.errorGetting = expectedError
    storage.expectedSid = expectedFactor.sid
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
    let expectedFactor = PushFactor(
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      entityIdentity: Constants.entityIdentityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let factorData = try! JSONEncoder().encode(expectedFactor)
    factorAPIClient.factorData = factorData
    factorMapper.expectedFactor = expectedFactor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    let expectedError = TestError.operationFailed
    storage.errorSaving = expectedError
    storage.expectedSid = expectedFactor.sid
    factorRepository.create(withPayload: factorPayload, success: { factor in
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
    XCTAssertNoThrow(try factorRepository.save(expectedFactor), "Save factor shouldn't throw")
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
    XCTAssertThrowsError(try factorRepository.save(expectedFactor), "Save factor should throw") { error in
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
    XCTAssertThrowsError(try factorRepository.save(expectedFactor), "Save factor should throw") { error in
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
    XCTAssertNoThrow(try factorRepository.get(withSid: expectedFactor.sid), "Get factor shouldn't throw")
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
    XCTAssertThrowsError(try factorRepository.get(withSid: expectedFactor.sid), "Get factor should throw") { error in
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
    XCTAssertThrowsError(try factorRepository.get(withSid: expectedFactor.sid), "Get factor should throw") { error in
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
