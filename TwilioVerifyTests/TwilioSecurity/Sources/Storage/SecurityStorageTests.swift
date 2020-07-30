//
//  StorageTests.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 6/4/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class SecurityStorageTests: XCTestCase {

  var keychain: KeychainMock!
  var storage: SecurityStorageProvider!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    keychain = KeychainMock()
    storage = SecurityStorage(keychain: keychain)
  }
  
  override func tearDownWithError() throws {
    clearKeychain()
  }
  
  func testSave_withValidValuesErrorAddingItem_shouldThrow() {
    let data = "data".data(using: .utf8)!
    let key = "key"
    let expectedErrorCode = errSecDuplicateItem
    let expectedLocalizedDescription = "The operation couldn’t be completed. (OSStatus error -25299.)"
    keychain.addItemStatus = [expectedErrorCode]
    XCTAssertThrowsError(try storage.save(data, withKey: key), "Save should throw") { error in
      let thrownError = error as NSError
      XCTAssertEqual(
        thrownError.code,
        Int(expectedErrorCode),
        "Error code should be \(expectedErrorCode), but was \(thrownError.code)"
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
    XCTAssertNoThrow(try storage.save(data, withKey: key), "Save should not throw")
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
  
  func testRemoveValue_valueExistsForKey_shouldReturnValue() {
    let expectedData = "data".data(using: .utf8)!
    let key = "key"
    var data: Data!
    keychain.keys = [expectedData as AnyObject]
    XCTAssertNoThrow(data = try storage.get(key), "Get should not throw")
    XCTAssertEqual(data, expectedData, "Data should be \(expectedData) but was \(data!)")
  }
  
  func testRemoveValue_valueDoesNotExist_shouldThrowError() {
    let key = "key"
    let expectedLocalizedDescription = "The operation couldn’t be completed. (OSStatus error -25300.)"
    keychain.deleteItemStatus = errSecItemNotFound
    XCTAssertThrowsError(try storage.removeValue(for: key), "Remove value should throw") { error in
      let thrownError = error as NSError
      XCTAssertEqual(
        thrownError.code,
        Int(errSecItemNotFound),
        "Error code should be \(errSecItemNotFound), but was \(thrownError.code)"
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
}

private extension SecurityStorageTests {
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
