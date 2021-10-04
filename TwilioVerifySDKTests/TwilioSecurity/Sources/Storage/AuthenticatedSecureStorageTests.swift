//
//  AuthenticatedSecureStorageTests.swift
//  TwilioVerifySDKTests
//
//  Copyright © 2021 Twilio.
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
import LocalAuthentication
@testable import TwilioVerifySDK

class AuthenticatedSecureStorageTests: XCTestCase {

  var testSubject: AuthenticatedSecureStorage!
  var keychainMock: KeychainMock!

  private enum MockErrors: Error {
    case unexpected
  }

  override func setUp() {
    keychainMock = .init()
    testSubject = .init(keychain: keychainMock, keychainQuery: KeychainQuery())
  }

  // MARK: - Save Data

  func testSave_withValidValuesSavingData_shouldNotThrow() {
    // Given
    let data = "testData".data(using: .utf8)
    let key = "testKey"
    let authenticator = AuthenticatorMock(context: MockContext())
    keychainMock.addItemStatus = [errSecSuccess]

    // When
    testSubject.save(data!, withKey: key, authenticator: authenticator) { [self] in
      // Then
      XCTAssertEqual(self.keychainMock.callsToAddItem, 1)
      XCTAssertEqual(self.keychainMock.callOrder.first, .addItem)
    } failure: { error in
      XCTFail("Should not retrieve error: \(error.localizedDescription)")
    }
  }

  func testSave_withValidValuesSavingDataButNotKeyChainAvailable_shouldThrow() {
    // Given
    let data = "testData".data(using: .utf8)
    let key = "testKey"
    let authenticator = AuthenticatorMock(context: MockContext())
    let expectedError = Int(errSecNotAvailable)
    keychainMock.addItemStatus = [errSecNotAvailable]

    // When
    testSubject.save(data!, withKey: key, authenticator: authenticator) {
      // Then
      XCTFail("Save data should fail, since there is not keychain available")
    } failure: { error in
      XCTAssertEqual(Optional(expectedError), (error as NSError).code)
    }
  }

  func testSave_withValidValuesSavingDataButFailedSaved_shouldReturnError() {
    // Given
    let data = "testData".data(using: .utf8)
    let key = "testKey"
    let authenticator = AuthenticatorMock(context: MockContext(evaluatePolicyResult: false))
    keychainMock.addItemStatus = [errSecNotAvailable]

    // When
    testSubject.save(data!, withKey: key, authenticator: authenticator) {
      // Then
      XCTFail("Save data should fail, since there is not keychain available")
    } failure: { error in
      XCTAssertEqual("Authentication failed", error.localizedDescription)
    }
  }

  func testSave_withValidValuesButUnexpectedError_shouldReturnError() {
    // Given
    let data = "testData".data(using: .utf8)
    let key = "testKey"
    let authenticator = AuthenticatorMock(context: MockContext())
    let expectedError = MockErrors.unexpected
    keychainMock.addItemStatus = [errSecSuccess]
    keychainMock.error = expectedError

    // When
    testSubject.save(data!, withKey: key, authenticator: authenticator) {
      // Then
      XCTFail("Save data should fail, since there is not keychain available")
    } failure: { error in
      XCTAssertEqual(expectedError.localizedDescription, error.localizedDescription)
    }
  }

  func testSave_withValidValuesSavingDataButFailedSavedAndError_shouldReturnError() {
    // Given
    let data = "testData".data(using: .utf8)
    let key = "testKey"
    let authenticator = AuthenticatorMock(context: MockContext(evaluatePolicyResult: false, evaluatePolicyError: MockErrors.unexpected))
    let expectedError = AuthenticatedSecureStorage.Errors.authenticationFailed(MockErrors.unexpected)
    keychainMock.addItemStatus = [errSecNotAvailable]

    // When
    testSubject.save(data!, withKey: key, authenticator: authenticator) {
      // Then
      XCTFail("Save data should fail, since there is not keychain available")
    } failure: { error in
      XCTAssertEqual(expectedError.localizedDescription, error.localizedDescription)
    }
  }

  // MARK: - Get Data

  func testGet_withValidValues_ShouldReturnData() {
    // Given
    let data = "testData".data(using: .utf8)
    let key = "testKey"
    let authenticator = AuthenticatorMock(context: MockContext())
    keychainMock.keys = [data] as [AnyObject]

    // When
    testSubject.get(key, authenticator: authenticator) { responseData in
      // Then
      XCTAssertEqual(String(data: responseData, encoding: .utf8), String(data: data!, encoding: .utf8))
    } failure: { error in
      XCTFail("Should not retrieve error: \(error.localizedDescription)")
    }
  }

  func testGet_withValidValuesWithUnexpectedError_ShouldReturnError() {
    // Given
    let key = "testKey"
    let authenticator = AuthenticatorMock(context: MockContext())
    let expectedError = MockErrors.unexpected
    keychainMock.error = expectedError

    // When
    testSubject.get(key, authenticator: authenticator) { _ in
      // Then
      XCTFail("Get Data should failed, because of an unexpected error")
    } failure: { error in
      XCTAssertEqual(expectedError.localizedDescription, error.localizedDescription)
    }
  }

  func testGet_withValidValuesButFailedAuthentication_ShouldReturnError() {
    // Given
    let data = "testData".data(using: .utf8)
    let key = "testKey"
    keychainMock.keys = [data] as [AnyObject]
    let mockContext = MockContext()
    let authenticator = AuthenticatorMock(context: mockContext)
    let expectedError = AuthenticatedSecureStorage.Errors.authenticationFailed(BiometricError.secAuthFailed)
    mockContext.canEvaluatePolicyError = BiometricError.secAuthFailed

    // When
    testSubject.get(key, authenticator: authenticator) { _ in
      // Then
      XCTFail("Get Data should failed, because of an authentication failure")
    } failure: { error in
      XCTAssertEqual(expectedError.localizedDescription, error.localizedDescription)
    }
  }

  // MARK: - Remove Value

  func testRemoveValue_WithValidKeyAndDataStored_ShouldSucceed() {
    // Given
    let key = "testKey"
    keychainMock.deleteItemStatus = errSecSuccess

    // When
    do {
      try testSubject.removeValue(for: key)
    } catch {
      XCTFail("Remove item should not throw")
    }

    // Then
    XCTAssertEqual(keychainMock.callOrder.first, .deleteItem)
  }

  func testRemoveValue_WithNoKeychainAvailable_ShouldThrow() {
    // Given
    let key = "testKey"
    keychainMock.deleteItemStatus = errSecNotAvailable

    // When
    do {
      try testSubject.removeValue(for: key)
      XCTFail("Remove item should throw")
    } catch {
      XCTAssertEqual(Int(errSecNotAvailable), (error as NSError).code)
    }

    // Then
    XCTAssertEqual(keychainMock.callOrder.first, .deleteItem)
  }

  // MARK: - Clear

  func testClear_WithValidAccess_ShouldSucceed() {
    // Given
    keychainMock.deleteItemStatus = errSecSuccess

    // When
    do {
      try testSubject.clear()
    } catch {
      XCTFail("Clear should not throw")
    }

    // Then
    XCTAssertEqual(keychainMock.callOrder.first, .deleteItem)
  }

  func testClear_WithNoKeychainAvailable_ShouldThrow() {
    // Given
    keychainMock.deleteItemStatus = errSecNotAvailable

    // When
    do {
      try testSubject.clear()
      XCTFail("Clear should throw")
    } catch {
      XCTAssertEqual(Int(errSecNotAvailable), (error as NSError).code)
    }

    // Then
    XCTAssertEqual(keychainMock.callOrder.first, .deleteItem)
  }

  // MARK: - Biometric Errors

  func testSave_withValidValuesSavingDataButFailedAuthentication_shouldThrowBiometricError() {
    // Given
    let data = "testData".data(using: .utf8)
    let key = "testKey"
    let mockContext = MockContext()
    let authenticator = AuthenticatorMock(context: mockContext)
    let expectedError = BiometricError.authenticationFailed
    mockContext.canEvaluatePolicyResult = false
    mockContext.canEvaluatePolicyError = LAError(.authenticationFailed)

    // When
    testSubject.save(data!, withKey: key, authenticator: authenticator) {
      // Then
      XCTFail("Save data should fail, since there is not keychain available")
    } failure: { error in
      XCTAssertEqual(expectedError.localizedDescription, error.localizedDescription)
    }
  }

  func testSave_withValidValuesSavingDataButUnexpectedError_shouldThrowUnexpectedError() {
    // Given
    let data = "testData".data(using: .utf8)
    let key = "testKey"
    let mockContext = MockContext()
    let authenticator = AuthenticatorMock(context: mockContext)
    let expectedError = "Authentication failed"
    mockContext.canEvaluatePolicyResult = false
    mockContext.canEvaluatePolicyError = MockErrors.unexpected

    // When
    testSubject.save(data!, withKey: key, authenticator: authenticator) {
      // Then
      XCTFail("Save data should fail, since there is not keychain available")
    } failure: { error in
      XCTAssertEqual(expectedError, error.localizedDescription)
    }
  }
}
