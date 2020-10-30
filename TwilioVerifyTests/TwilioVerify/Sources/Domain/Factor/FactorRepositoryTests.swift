//
//  FactorRepositoryTests.swift
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
@testable import TwilioVerify

// swiftlint:disable type_body_length file_length force_try force_cast
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
      identity: Constants.identityValue,
      config: [:], binding: [:],
      accessToken: Constants.accessToken)
    let factor = Constants.generateFactor()
    let factorData = try! JSONEncoder().encode(factor)
    factorAPIClient.factorData = factorData
    factorMapper.expectedFactor = factor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    storage.expectedSid = factor.sid
    storage.factorData = factorData
    var factorResponse: Factor?
    factorRepository.create(withPayload: factorPayload, success: { factor in
      factorResponse = factor as? PushFactor
      successExpectation.fulfill()
    }) { _ in
      XCTFail()
      successExpectation.fulfill()
    }
    wait(for: [successExpectation], timeout: 5)
    XCTAssertTrue(factorResponse is PushFactor, "Factor should be \(PushFactor.self)")
    XCTAssertEqual(factorResponse?.sid, factor.sid, "Factor sid should be \(factor.sid) but was \(factorResponse!.sid)")
    XCTAssertEqual(factorResponse?.accountSid, factor.accountSid, "Factor accountSid should be \(factor.accountSid) but was \(factorResponse!.accountSid)")
    XCTAssertEqual(factorResponse?.createdAt, factor.createdAt, "Factor createdAt should be \(factor.createdAt) but was \(factorResponse!.createdAt)")
    XCTAssertEqual(factorResponse?.identity, factor.identity, "Factor identity should be \(factor.identity) but was \(factorResponse!.identity)")
    XCTAssertEqual(factorResponse?.friendlyName, factor.friendlyName, "Factor friendlyName should be \(factor.friendlyName) but was \(factorResponse!.friendlyName)")
    XCTAssertEqual(factorResponse?.serviceSid, factor.serviceSid, "Factor serviceSid should be \(factor.serviceSid) but was \(factorResponse!.serviceSid)")
    XCTAssertEqual(factorResponse?.status, factor.status, "Factor status should be \(factor.status) but was \(factorResponse!.status)")
    XCTAssertEqual((factorResponse as! PushFactor).config.credentialSid,
                   factor.config.credentialSid,
                   "Factor credentialSid should be \(factor.config.credentialSid) but was \((factorResponse as! PushFactor).config.credentialSid)")
  }

  func testCreateFactor_withInvalidResponse_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let factorPayload = CreateFactorPayload(
      friendlyName: Constants.friendlyNameValue,
      type: Constants.pushType,
      serviceSid: Constants.serviceSidValue,
      identity: Constants.identityValue,
      config: [:], binding: [:],
      accessToken: Constants.accessToken)
    let expectedError = NetworkError.invalidData
    factorAPIClient.error = expectedError
    factorRepository.create(withPayload: factorPayload, success: { _ in
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
    let factor = Constants.generateFactor()
    let factorPayload = CreateFactorPayload(
      friendlyName: Constants.friendlyNameValue,
      type: Constants.pushType,
      serviceSid: Constants.serviceSidValue,
      identity: Constants.identityValue,
      config: [:], binding: [:],
      accessToken: Constants.accessToken)
    let factorData = try! JSONEncoder().encode(factor)
    factorAPIClient.factorData = factorData
    let expectedError = MapperError.invalidArgument
    factorMapper.fromAPIError = expectedError
    factorRepository.create(withPayload: factorPayload, success: { _ in
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
    let factor = Constants.generateFactor()
    let factorPayload = CreateFactorPayload(
      friendlyName: Constants.friendlyNameValue,
      type: Constants.pushType,
      serviceSid: Constants.serviceSidValue,
      identity: Constants.identityValue,
      config: [:], binding: [:],
      accessToken: Constants.accessToken)
    let factorData = try! JSONEncoder().encode(factor)
    factorAPIClient.factorData = factorData
    factorMapper.expectedFactor = factor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    let expectedError = TestError.operationFailed
    storage.errorGetting = expectedError
    storage.expectedSid = factor.sid
    factorRepository.create(withPayload: factorPayload, success: { _ in
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
    let factor = Constants.generateFactor()
    let factorPayload = CreateFactorPayload(
      friendlyName: Constants.friendlyNameValue,
      type: Constants.pushType,
      serviceSid: Constants.serviceSidValue,
      identity: Constants.identityValue,
      config: [:], binding: [:],
      accessToken: Constants.accessToken)
    let factorData = try! JSONEncoder().encode(factor)
    factorAPIClient.factorData = factorData
    factorMapper.expectedFactor = factor
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = factorPayload
    let expectedError = TestError.operationFailed
    storage.errorSaving = expectedError
    storage.expectedSid = factor.sid
    factorRepository.create(withPayload: factorPayload, success: { _ in
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
    let factor = Constants.generateFactor()
    let payload = "authPayload"
    let expectedFactorStatus = FactorStatus.verified
    let response: [String: Any] = [Constants.sidKey: Constants.expectedSidValue,
                                   Constants.friendlyNameKey: Constants.friendlyNameValue,
                                   Constants.accountSidKey: Constants.expectedAccountSid,
                                   Constants.serviceSidKey: Constants.serviceSidValue,
                                   Constants.statusKey: expectedFactorStatus.rawValue]
    let responseData = try! JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
    factorAPIClient.expectedFactorSid = factor.sid
    factorAPIClient.statusData = responseData
    storage.expectedSid = factor.sid
    storage.factorData = responseData
    let expectedFactor = PushFactor(
      status: expectedFactorStatus,
      sid: Constants.expectedSidValue,
      friendlyName: Constants.friendlyNameValue,
      accountSid: Constants.expectedAccountSid,
      serviceSid: Constants.serviceSidValue,
      identity: Constants.identityValue,
      createdAt: Date(),
      config: Config(credentialSid: Constants.expectedCredentialSid))
    let expectedFactorData = try! JSONEncoder().encode(expectedFactor)
    factorMapper.expectedFactor = factor
    factorMapper.expectedData = expectedFactorData
    factorMapper.expectedStatusData = responseData

    var factorResponse: Factor?
    factorRepository.verify(factor, payload: payload, success: { factor in
      factorResponse = factor
      successExpectation.fulfill()
    }) { _ in
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
    factorRepository.verify(Constants.generateFactor(), payload: "", success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { failureError in
      error = failureError
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual((error as! NetworkError).errorDescription, expectedError.errorDescription)
  }

  func testVerifyFactor_withErrorInMapper_shouldFail() {
    let failureExpectation = expectation(description: "Wait for failure response")
    let factor = Constants.generateFactor()
    let payload = "authPayload"
    let response: [String: Any] = [Constants.sidKey: Constants.expectedSidValue]
    let responseData = try! JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
    factorAPIClient.expectedFactorSid = factor.sid
    factorAPIClient.statusData = responseData
    factorMapper.expectedStatusData = responseData
    var error: Error!
    factorRepository.verify(factor, payload: payload, success: { _ in
      XCTFail()
      failureExpectation.fulfill()
    }) { failureError in
      error = failureError
      failureExpectation.fulfill()
    }
    wait(for: [failureExpectation], timeout: 5)
    XCTAssertEqual((error as! MapperError).errorDescription, MapperError.invalidArgument.errorDescription,
                   "Error description should be \(MapperError.invalidArgument.errorDescription!) but was \((error as! MapperError).errorDescription!)")
  }

  func testUpdateFactor_withValidResponse_shouldSuceed() {
    let expectation = self.expectation(description: "testUpdateFactor_withValidResponse_shouldSuceed")
    let payload = Constants.updateFactorPayload
    let expectedFactor = Constants.generateFactor()
    let factorData = try! JSONEncoder().encode(expectedFactor)
    storage.expectedSid = payload.factorSid
    storage.factorData = factorData
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = payload
    factorAPIClient.expectedFactorSid = payload.factorSid
    factorAPIClient.statusData = factorData
    var factor: Factor!
    factorRepository.update(withPayload: payload, success: { response in
      factor = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(factor.sid, expectedFactor.sid, "Factor should be \(expectedFactor) but was \(factor!)")
  }

  func testUpdateFactor_withInvalidResponse_shouldFail() {
    let expectation = self.expectation(description: "testUpdateFactor_withInvalidResponse_shouldFail")
    let payload = Constants.updateFactorPayload
    let factorData = try! JSONEncoder().encode(Constants.generateFactor())
    storage.expectedSid = payload.factorSid
    storage.factorData = factorData
    factorMapper.expectedData = factorData
    let expectedError = NetworkError.invalidData
    factorAPIClient.error = expectedError
    var error: Error!
    factorRepository.update(withPayload: payload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual((error as! NetworkError).errorDescription, expectedError.errorDescription)
  }

  func testUpdateFactor_withErrorInMapper_shouldFail() {
    let expectation = self.expectation(description: "testUpdateFactor_withErrorInMapper_shouldFail")
    let payload = Constants.updateFactorPayload
    let factorData = try! JSONEncoder().encode(Constants.generateFactor())
    storage.expectedSid = payload.factorSid
    storage.factorData = factorData
    factorMapper.expectedData = factorData
    factorMapper.expectedFactorPayload = payload
    let expectedError = MapperError.illegalArgument
    factorMapper.fromAPIError = expectedError
    factorAPIClient.expectedFactorSid = payload.factorSid
    factorAPIClient.statusData = factorData
    var error: Error!
    factorRepository.update(withPayload: payload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual((error as! MapperError).errorDescription, expectedError.errorDescription)
  }

  func testUpdateFactor_withErrorInStorage_shouldFail() {
    let expectation = self.expectation(description: "testUpdateFactor_withErrorInStorage_shouldFail")
    let payload = Constants.updateFactorPayload
    let expectedError = StorageError.error("Factor not found")
    storage.errorGetting = expectedError
    storage.expectedSid = payload.factorSid
    var error: Error!
    factorRepository.update(withPayload: payload, success: { _ in
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual((error as! StorageError).errorDescription, expectedError.errorDescription)
  }

  func testSaveFactor_withFactorSuccessfullyStored_shouldSucceed() {
    let factor = Constants.generateFactor()
    let factorData = try! JSONEncoder().encode(factor)
    storage.expectedSid = factor.sid
    storage.factorData = factorData
    factorMapper.expectedFactor = factor
    factorMapper.expectedData = factorData
    XCTAssertNoThrow(try factorRepository.save(factor), "Save factor shouldn't throw")
  }

  func testSaveFactor_withStorageError_shouldFail() {
    let factor = Constants.generateFactor()
    factorMapper.expectedFactor = factor
    let expectedError = TestError.operationFailed
    storage.expectedSid = factor.sid
    storage.errorSaving = expectedError
    XCTAssertThrowsError(try factorRepository.save(factor), "Save factor should throw") { error in
      XCTAssertEqual((error as! TestError), expectedError)
    }
  }

  func testSaveFactor_withMapperError_shouldFail() {
    let factor = Constants.generateFactor()
    let expectedError = MapperError.invalidArgument
    factorMapper.expectedFactor = factor
    factorMapper.error = expectedError
    storage.expectedSid = factor.sid
    XCTAssertThrowsError(try factorRepository.save(factor), "Save factor should throw") { error in
      XCTAssertEqual((error as! MapperError), expectedError)
    }
  }

  func testGetFactor_withStoredFactor_shouldSucceed() {
    let factor = Constants.generateFactor()
    let factorData = try! JSONEncoder().encode(factor)
    storage.expectedSid = factor.sid
    storage.factorData = factorData
    factorMapper.expectedData = factorData
    XCTAssertNoThrow(try factorRepository.get(withSid: factor.sid), "Get factor shouldn't throw")
  }

  func testGetFactor_withStorageError_shouldFail() {
    let factor = Constants.generateFactor()
    let expectedError = TestError.operationFailed
    storage.expectedSid = factor.sid
    storage.errorGetting = expectedError
    XCTAssertThrowsError(try factorRepository.get(withSid: factor.sid), "Get factor should throw") { error in
      XCTAssertEqual((error as! TestError), expectedError)
    }
  }

  func testGetFactor_withMapperError_shouldFail() {
    let factor = Constants.generateFactor()
    let factorData = try! JSONEncoder().encode(factor)
    let expectedError = MapperError.invalidArgument
    storage.expectedSid = factor.sid
    storage.factorData = factorData
    factorMapper.error = expectedError
    XCTAssertThrowsError(try factorRepository.get(withSid: factor.sid), "Get factor should throw") { error in
      XCTAssertEqual((error as! MapperError), expectedError)
    }
  }

  func testDeleteFactor_withSuccessResponse_shouldDeleteFactorStored() {
    let expectation = self.expectation(description: "testDeleteFactor_withSuccessResponse_shouldDeleteFactorStored")
    let factor = Constants.generateFactor()
    factorRepository.delete(factor, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(storage.removedKey, factor.sid,
                   "Key to be removed should be \(factor.sid) but was \(storage.removedKey!)")
  }

  func testDeleteFactor_withErrorResponse_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withErrorResponse_shouldFail")
    let expectedError = TestError.operationFailed
    factorAPIClient.error = expectedError
    var error: Error!
    factorRepository.delete(Constants.generateFactor(), success: {
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
    let factor = Constants.generateFactor()
    storage.errorRemoving = expectedError
    storage.expectedSid = factor.sid
    var error: Error!
    factorRepository.delete(factor, success: {
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

  func testGetAllFactors_withFactorsStored_shouldSucced() {
    let factor1ExpectedSid = "sid123"
    let factor1 = Constants.generateFactor(withSid: factor1ExpectedSid)
    let factor2ExpectedSid = "sid000"
    let factor2 = Constants.generateFactor(withSid: factor2ExpectedSid)
    let factorData1 = try! JSONEncoder().encode(factor1)
    let factorData2 = try! JSONEncoder().encode(factor2)
    let expectedDataList = [factorData1, factorData2]
    storage.factorsData = expectedDataList
    factorMapper.expectedDataList = expectedDataList
    var factors: [Factor]!
    XCTAssertNoThrow(factors = try factorRepository.getAll())
    XCTAssertEqual(factors.count, expectedDataList.count, "Factors count should be \(expectedDataList.count) but were \(factors.count)")
    XCTAssertEqual(factors.first?.sid, factor1ExpectedSid, "Factor at first position should be \(factor1) but was \(factors.first!)")
    XCTAssertEqual(factors.last?.sid, factor2ExpectedSid, "Factor at last position should be \(factor2) but was \(factors.last!)")
  }

  func testGetAllFactors_withSomeInvalidDataStored_shouldReturnOnlyFactors() {
    let factor1ExpectedSid = "sid123"
    let factor1 = Constants.generateFactor(withSid: factor1ExpectedSid)
    let factor2ExpectedSid = "sid000"
    let factor2 = Constants.generateFactor(withSid: factor2ExpectedSid)
    let factorData1 = try! JSONEncoder().encode(factor1)
    let factorData2 = try! JSONEncoder().encode(factor2)
    let factorList = [factorData1, factorData2]
    let invalidData = "invalidData".data(using: .utf8)!
    let expectedDataList = factorList + [invalidData]
    storage.factorsData = expectedDataList
    factorMapper.expectedDataList = expectedDataList
    var factors: [Factor]!
    XCTAssertNoThrow(factors = try factorRepository.getAll())
    XCTAssertEqual(factors.count, factorList.count, "Factors count should be \(factorList.count) but were \(factors.count)")
    XCTAssertEqual(factors.first?.sid, factor1ExpectedSid, "Factor at first position should be \(factor1) but was \(factors.first!)")
    XCTAssertEqual(factors.last?.sid, factor2ExpectedSid, "Factor at last position should be \(factor2) but was \(factors.last!)")
  }

  func testGetAllFactors_withStorageError_shouldFail() {
    let expectedError = TestError.operationFailed
    storage.errorGettingAll = expectedError
    var error: Error!
    XCTAssertThrowsError(try factorRepository.getAll()) { operationResult in
      error = operationResult
    }
    XCTAssertEqual((error as! TestError), expectedError)
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
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
    static let identityValue = "identity123"
    static let accessToken = "accessToken"
    static let expectedSidValue = "sid123"
    static let expectedAccountSid = "accountSid123"
    static let expectedCredentialSid = "credentialSid123"
    static let updateFactorPayload = UpdateFactorDataPayload(
      friendlyName: Constants.friendlyNameValue,
      type: Constants.pushType,
      serviceSid: Constants.serviceSidValue,
      identity: Constants.identityValue,
      config: [:],
      factorSid: Constants.expectedSidValue)
    static func generateFactor(withSid sid: String = Constants.expectedSidValue) -> PushFactor {
      PushFactor(
        sid: sid,
        friendlyName: Constants.friendlyNameValue,
        accountSid: Constants.expectedAccountSid,
        serviceSid: Constants.serviceSidValue,
        identity: Constants.identityValue,
        createdAt: Date(),
        config: Config(credentialSid: Constants.expectedCredentialSid))
    }
  }
}
