//
//  SecureStorageTests.swift
//  TwilioSecurityTests
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

// swiftlint:disable force_cast
class SecureStorageTests: XCTestCase {

  var keychain: KeychainMock!
  var storage: SecureStorageProvider!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    keychain = KeychainMock()
    storage = SecureStorage(keychain: keychain, keychainQuery: KeychainQuery(accessGroup: nil))
  }
  
  override func tearDownWithError() throws {
    clearKeychain()
  }
  
  func testSave_withValidValuesErrorAddingItem_shouldThrow() {
    let data = "data".data(using: .utf8)!
    let key = "key"
    let expectedErrorCode = errSecDuplicateItem
    let expectedLocalizedDescription = "Invalid status code operation received: -25299"
    keychain.deleteItemStatus = errSecSuccess
    keychain.addItemStatus = [expectedErrorCode]

    XCTAssertThrowsError(
      try storage.save(data, withKey: key, withServiceName: "service"),
      "Save should throw"
    ) { error in
      guard let thrownError = error as? SecureStorageError,
            case .invalidStatusCode(let code) = thrownError else {
        XCTFail("Unexpected error received")
        return
      }

      XCTAssertEqual(
        code,
        Int(expectedErrorCode),
        "Error code should be \(expectedErrorCode), but was \(code)"
      )

      XCTAssertEqual(
        thrownError.domain,
        NSOSStatusErrorDomain,
        "Error domain should be \(NSOSStatusErrorDomain), but was \(thrownError.domain)"
      )
      
      XCTAssertEqual(
        thrownError.localizedDescription,
        expectedLocalizedDescription,
        "Error localized description should be \(expectedLocalizedDescription), but was \(thrownError.localizedDescription)"
      )
    }
  }
  
  func testSave_withValidValues_shouldSaveValue() {
    let data = "data".data(using: .utf8)!
    let key = "key"
    keychain.addItemStatus = [errSecSuccess]
    keychain.deleteItemStatus = errSecSuccess
    XCTAssertNoThrow(try storage.save(data, withKey: key, withServiceName: "service"), "Save should not throw")
  }
  
  func testGet_valueExistsForKey_shouldReturnValue() {
    let expectedData = "data".data(using: .utf8)!
    let key = "key"
    var data: Data!
    keychain.keys = [expectedData as AnyObject]
    XCTAssertNoThrow(data = try storage.get(key), "Get should not throw")
    XCTAssertEqual(data, expectedData, "Data should be \(expectedData) but was \(data!)")
  }
  
  func testGet_valueDoesNotExist_shouldThrowError() {
    let key = "key"
    keychain.error = TestError.operationFailed
    XCTAssertThrowsError(try storage.get(key), "Get should throw") { error in
      XCTAssertEqual(
        error as! TestError,
        TestError.operationFailed,
        "Error should be \(TestError.operationFailed), but was \(error)"
      )
    }
  }
  
  func testGetAllData_withExistingValues_shouldReturnValues() {
    let expectedData1 = "data".data(using: .utf8)!
    let valueData1 = [kSecValueData as String: expectedData1]
    let expectedData2 = "data2".data(using: .utf8)!
    let valueData2 = [kSecValueData as String: expectedData2]
    var data: [Data?]!
    keychain.keys = [[valueData1, valueData2] as AnyObject]
    XCTAssertNoThrow(data = try storage.getAll(withServiceName: nil), "Get all should not throw")
    XCTAssertEqual(data.first, expectedData1, "Data should be \(expectedData1) but was \(data!.first!!)")
    XCTAssertEqual(data.last, expectedData2, "Data should be \(expectedData2) but was \(data!.last!!)")
  }
  
  func testGetAllData_withoutDataSaved_shouldReturnEmptyArray() {
    var data: [Data?]!
    keychain.keys = ["data".data(using: .utf8)! as AnyObject]
    XCTAssertNoThrow(data = try storage.getAll(withServiceName: nil), "Get all should not throw")
    XCTAssertTrue(data.isEmpty)
  }
  
  func testRemoveValue_valueExistsForKey_shouldReturnValue() {
    let key = "key"
    keychain.deleteItemStatus = errSecSuccess
    XCTAssertNoThrow(try storage.removeValue(for: key), "Remove value should not throw")
  }
  
  func testRemoveValue_valueDoesNotExist_shouldNotThrowError() {
    let key = "key"
    keychain.deleteItemStatus = errSecItemNotFound
    XCTAssertNoThrow(try storage.removeValue(for: key), "Remove value should not throw")
  }
  
  func testClear_itemsExist_shouldClearKeychain() {
    let expectedData2 = "data2".data(using: .utf8)!
    let valueData2 = [kSecValueData as String: expectedData2]
    keychain.keys = [[valueData2] as AnyObject]
    keychain.deleteItemStatus = errSecSuccess
    XCTAssertNoThrow(try storage.clear(withServiceName: "service"), "Clear should not throw")
    XCTAssertTrue(keychain.callOrder.contains(.deleteItem), "Delete should be called")
  }
  
  func testClear_noItems_shouldNotClearKeychain() {
    keychain.error = NSError(domain: "No items", code: Int(errSecItemNotFound), userInfo: nil)
    XCTAssertNoThrow(try storage.clear(withServiceName: "service"), "Clear should not throw")
    XCTAssertFalse(keychain.callOrder.contains(.deleteItem), "Delete should not be called")
  }
  
  func testClear_itemsExistAndDeleteStatusError_shouldThrowError() {
    let expectedLocalizedDescription = "Invalid status code operation received: -25300"
    let expectedData2 = "data2".data(using: .utf8)!
    let valueData2 = [kSecValueData as String: expectedData2]
    keychain.keys = [[valueData2] as AnyObject]
    keychain.deleteItemStatus = errSecItemNotFound

    XCTAssertThrowsError(
      try storage.clear(withServiceName: "service"),
      "Clear should throw"
    ) { error in
      guard let thrownError = error as? SecureStorageError,
            case .invalidStatusCode(let code) = thrownError else {
        XCTFail("Unexpected error received")
        return
      }

      XCTAssertEqual(
        code,
        Int(errSecItemNotFound),
        "Error code should be \(errSecItemNotFound), but was \(code)"
      )

      XCTAssertEqual(
        thrownError.domain,
        NSOSStatusErrorDomain,
        "Error domain should be \(NSOSStatusErrorDomain), but was \(thrownError.domain)"
      )
      
      XCTAssertEqual(
        thrownError.localizedDescription,
        expectedLocalizedDescription,
        "Error localized description should be \(expectedLocalizedDescription), but was \(thrownError.localizedDescription)"
      )
    }
  }

  func testGet_valueExistsForMultipleTries_shouldReturnValueIfAnyOfTheTriesSucceed() throws {
    // Given
    let expectation = expectation(description: "Test multiple tries of storage.Get")
    guard let expectedData = "data".data(using: .utf8) else {
      XCTFail("failed to encrypt data")
      return
    }

    let key = "key"
    var data: Data?
    keychain.error = TestError.operationFailed
    keychain.keys = [expectedData as AnyObject, expectedData as AnyObject, expectedData as AnyObject]

    keychain.copyItemMitmatchingHandler = { [weak self] in
      if self?.keychain.callsToCopyItemMatching == 0 {
        self?.keychain.error = nil
        expectation.fulfill()
      }
    }

    // When
    XCTAssertNoThrow(data = try storage.get(key), "Get should not throw if the data is retrieve")

    // Then
    wait(for: [expectation], timeout: 1.0)
    XCTAssertEqual(data, expectedData, "Data should be \(expectedData) but was \(data)")
  }

  func testGet_valueExistsForMultipleTries_shouldThrowIfTheErrorPersist() throws {
    // Given
    guard let expectedData = "data".data(using: .utf8) else {
      XCTFail("failed to encrypt data")
      return
    }

    let key = "key"
    var data: Data?
    keychain.error = TestError.operationFailed
    keychain.keys = [expectedData as AnyObject]

    // When
    XCTAssertThrowsError(data = try storage.get(key), "Get should throw if the error persist during retries")

    // Then
    XCTAssertEqual(data, nil, "Data should be nil")
  }
}

private extension SecureStorageTests {
  func clearKeychain() {
    let secItemClasses = [kSecClassGenericPassword,
                          kSecClassInternetPassword,
                          kSecClassCertificate,
                          kSecClassKey,
                          kSecClassIdentity]
    secItemClasses.forEach {
      SecItemDelete([kSecClass: $0] as CFDictionary)
    }
  }
}
