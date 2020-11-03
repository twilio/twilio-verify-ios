//
//  PushFactoryTests.swift
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

// swiftlint:disable force_cast type_body_length file_length
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
  
  func testCreateFactor_factorHasWrongType_shouldFail() {
    let expectation = self.expectation(description: "testCreateFactor_factorHasWrongType_shouldFail")
    let expectedError = TwilioVerifyError.networkError(error: NetworkError.invalidData as NSError)
    var error: TwilioVerifyError!
    keyStorage.createKeyResult = Constants.data
    repository.factor = Constants.fakeFactor
    
    factory.createFactor(withAccessToken: Constants.accessToken, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
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
  
  func testCreateFactor_withErrorCreatingKey_shouldFail() {
    let expectation = self.expectation(description: "testCreateFactor_withErrorCreatingKey_shouldFail")
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    keyStorage.errorCreatingKey = TestError.operationFailed
    
    factory.createFactor(withAccessToken: Constants.accessToken, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
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
    
    factory.createFactor(withAccessToken: Constants.accessToken, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
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
    keyStorage.errorDeletingKey = TestError.operationFailed
    repository.error = TestError.operationFailed
    
    factory.createFactor(withAccessToken: Constants.accessToken, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
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
    
    factory.createFactor(withAccessToken: Constants.accessToken, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
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
  
  func testCreateFactor_withErrorDeletingFactorWhenSavingItFails_shouldFail() {
    let expectation = self.expectation(description: "testCreateFactor_withErrorSavingFactor_shouldFail")
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    keyStorage.createKeyResult = Constants.data
    keyStorage.error = TestError.operationFailed
    repository.saveError = TestError.operationFailed
    repository.factor = Constants.factor
    
    factory.createFactor(withAccessToken: Constants.accessToken, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
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
    
    factory.createFactor(withAccessToken: Constants.accessToken, friendlyName: Constants.friendlyName, pushToken: Constants.pushToken,
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
    XCTAssertEqual(pushFactor.identity, Constants.factor.identity,
                   "Identity should be \(Constants.factor.identity) but was \(pushFactor.identity)")
    XCTAssertEqual(pushFactor.createdAt, Constants.factor.createdAt,
                   "Creation date should be \(Constants.factor.createdAt) but was \(pushFactor.createdAt)")
    XCTAssertEqual(pushFactor.config.credentialSid, Constants.factor.config.credentialSid,
                   "Credential Sid should be \(Constants.factor.config.credentialSid) but was \(pushFactor.config.credentialSid)")
  }
  
  func testVerifyFactor_errorGettingFactor_shouldFail() {
    let expectation = self.expectation(description: "testVerifyFactor_errorGettingFactor_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    repository.error = TestError.operationFailed
    
    factory.verifyFactor(withSid: "sid", success: { _ in
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
  
  func testVerifyFactor_factorWithWrongType_shouldFail() {
    let expectation = self.expectation(description: "testVerifyFactor_factorWithWrongType_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: StorageError.error("Factor not found") as NSError)
    var error: TwilioVerifyError!
    repository.factor = Constants.fakeFactor
    
    factory.verifyFactor(withSid: "sid", success: { _ in
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

  func testVerifyFactor_factorIsMissingAlias_shouldFail() {
    let expectation = self.expectation(description: "testVerifyFactor_factorIsMissingAlias_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: StorageError.error("Alias not found") as NSError)
    var error: TwilioVerifyError!
    repository.factor = Constants.factor
    
    factory.verifyFactor(withSid: "sid", success: { _ in
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
  
  func testVerifyFactor_errorCreatingSignature_shouldFail() {
    let expectation = self.expectation(description: "testVerifyFactor_errorCreatingSignature_shouldFail")
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    var factor = Constants.factor
    factor.keyPairAlias = "alias"
    repository.factor = factor
    keyStorage.error = TestError.operationFailed
    
    factory.verifyFactor(withSid: "sid", success: { _ in
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
  
  func testVerifyFactor_errorVerifyingFactor_shouldFail() {
    let expectation = self.expectation(description: "testVerifyFactor_errorVerifyingFactor_shouldFail")
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    var factor = Constants.factor
    factor.keyPairAlias = "alias"
    repository.factor = factor
    repository.verifyError = TestError.operationFailed
    keyStorage.signResult = Constants.data.data(using: .utf8)!
    
    factory.verifyFactor(withSid: "sid", success: { _ in
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
  
  func testVerifyFactor_withoutErrors_shouldSucceed() {
    let expectation = self.expectation(description: "testVerifyFactor_withoutErrors_shouldSucceed")
    var pushFactor: PushFactor!
    var factor = Constants.factor
    factor.keyPairAlias = "alias"
    repository.factor = factor
    keyStorage.signResult = Constants.data.data(using: .utf8)!
    
    factory.verifyFactor(withSid: "sid", success: { factor in
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
    XCTAssertEqual(pushFactor.identity, Constants.factor.identity,
                   "Identity should be \(Constants.factor.identity) but was \(pushFactor.identity)")
    XCTAssertEqual(pushFactor.createdAt, Constants.factor.createdAt,
                   "Creation date should be \(Constants.factor.createdAt) but was \(pushFactor.createdAt)")
    XCTAssertEqual(pushFactor.config.credentialSid, Constants.factor.config.credentialSid,
                   "Credential Sid should be \(Constants.factor.config.credentialSid) but was \(pushFactor.config.credentialSid)")
  }
  
  func testUpdateFactor_withStoredFactorAndValidResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testVerifyFactor_withoutErrors_shouldSucceed")
    let factor = Constants.factor
    repository.factor = factor
    var pushFactor: PushFactor!
    factory.updateFactor(withSid: factor.sid, withPushToken: Constants.pushToken, success: { response in
      pushFactor = response as? PushFactor
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
    XCTAssertEqual(pushFactor.identity, Constants.factor.identity,
                   "Identity should be \(Constants.factor.identity) but was \(pushFactor.identity)")
    XCTAssertEqual(pushFactor.createdAt, Constants.factor.createdAt,
                   "Creation date should be \(Constants.factor.createdAt) but was \(pushFactor.createdAt)")
    XCTAssertEqual(pushFactor.config.credentialSid, Constants.factor.config.credentialSid,
                   "Credential Sid should be \(Constants.factor.config.credentialSid) but was \(pushFactor.config.credentialSid)")
  }
  
  func testUpdateFactor_errorGettingFactor_shouldFail() {
    let expectation = self.expectation(description: "testUpdateFactor_errorGettingFactor_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    repository.error = TestError.operationFailed
    
    factory.updateFactor(withSid: Constants.factor.sid, withPushToken: Constants.pushToken, success: { _ in
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
  
  func testUpdateFactor_factorWithWrongType_shouldFail() {
    let expectation = self.expectation(description: "testUpdateFactor_factorWithWrongType_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: StorageError.error("Factor not found") as NSError)
    var error: TwilioVerifyError!
    repository.factor = Constants.fakeFactor
    factory.updateFactor(withSid: Constants.factor.sid, withPushToken: Constants.pushToken, success: { _ in
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
  
  func testUpdateFactor_errorVerifyingFactor_shouldFail() {
    let expectation = self.expectation(description: "testUpdateFactor_errorVerifyingFactor_shouldFail")
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    let factor = Constants.factor
    repository.factor = factor
    repository.updateError = TestError.operationFailed
    factory.updateFactor(withSid: factor.sid, withPushToken: Constants.pushToken, success: { _ in
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
  
  func testDeleteFactor_withSuccessResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testDeleteFactor_withSuccessResponse_shouldSucceed")
    var factor = Constants.factor
    factor.keyPairAlias = "alias"
    repository.factor = factor
    factory.deleteFactor(withSid: Constants.factor.sid, success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(factor.keyPairAlias, keyStorage.deletedAlias!,
                   "Deleted alias should be \(factor.keyPairAlias!) but was \(keyStorage.deletedAlias!)")
  }
  
  func testDeleteFactor_withFactorIsMissingAlias_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withFactorIsMissingAlias_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: StorageError.error("Alias not found") as NSError)
    var error: TwilioVerifyError!
    repository.factor = Constants.factor
    factory.deleteFactor(withSid: Constants.factor.sid, success: {
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
  
  func testDeleteFactor_withErrorGettingFactor_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withErrorGettingFactor_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    repository.error = TestError.operationFailed
    
    factory.deleteFactor(withSid: Constants.factor.sid, success: {
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
  
  func testDeleteFactor_withWrongTypeFactor_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withWrongTypeFactor_shouldFail")
    let expectedError = TwilioVerifyError.storageError(error: StorageError.error("Factor not found") as NSError)
    var error: TwilioVerifyError!
    repository.factor = Constants.fakeFactor
    
    factory.deleteFactor(withSid: Constants.factor.sid, success: {
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
  
  func testDeleteFactor_withErrorResponse_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withErrorResponse_shouldFail")
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    var factor = Constants.factor
    factor.keyPairAlias = "alias"
    repository.factor = factor
    repository.deleteError = TestError.operationFailed
    
    factory.deleteFactor(withSid: Constants.factor.sid, success: {
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

  func testDeleteFactor_withErrorDeletingKeyPair_shouldFail() {
    let expectation = self.expectation(description: "testDeleteFactor_withErrorDeletingKeyPair_shouldFail")
    let expectedError = TwilioVerifyError.keyStorageError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    var factor = Constants.factor
    factor.keyPairAlias = "alias"
    repository.factor = factor
    keyStorage.errorDeletingKey = TestError.operationFailed
    
    factory.deleteFactor(withSid: Constants.factor.sid, success: {
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
  
  func testDeleteAllFactors_withErrorGettingFactors_shouldThrow() {
    repository.factors = [Constants.factor]
    let expectedError = TwilioVerifyError.storageError(error: StorageError.error("Factors not found") as NSError)
    repository.error = TestError.operationFailed
    XCTAssertThrowsError(try factory.deleteAllFactors(), "Delete all factors should throw") { error in
      XCTAssertEqual((error as! TwilioVerifyError).localizedDescription,
                     expectedError.localizedDescription)
    }
  }
  
  func testDeleteAllFactors_withErrorDeletingFactor_shouldThrow() {
    repository.factors = [Constants.factor]
    repository.deleteError = TestError.operationFailed
    XCTAssertThrowsError(try factory.deleteAllFactors(), "Delete all factors should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testDeleteAllFactors_withErrorDeletingKeyPair_shouldThrow() {
    var factor = Constants.factor
    factor.keyPairAlias = "alias"
    repository.factors = [factor]
    keyStorage.errorDeletingKey = TestError.operationFailed
    XCTAssertThrowsError(try factory.deleteAllFactors(), "Delete all factors should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testDeleteAllFactors_withoutErrors_shouldClearSecureStorage() {
    repository.factors = [Constants.factor]
    XCTAssertNoThrow(try factory.deleteAllFactors(), "Delete all factors should not throw")
  }
}

private extension PushFactoryTests {
  struct Constants {
    static let accessToken = "accessToken"
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
      identity: Constants.identity,
      createdAt: Date(),
      config: Constants.config
    )
    static let fakeFactor = FactorMock(
      status: .unverified,
      sid: "sid",
      friendlyName: Constants.friendlyName,
      accountSid: "accountSid",
      serviceSid: Constants.serviceSid,
      identity: Constants.identity,
      type: .push,
      createdAt: Date())
  }
}
