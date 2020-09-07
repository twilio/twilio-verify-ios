//
//  StorageTests.swift
//  TwilioVerifyTests
//
//  Created by Santiago Avila on 6/9/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

// swiftlint:disable force_cast
class StorageTests: XCTestCase {

  var secureStorage: SecureStorageMock!
  var storage: StorageProvider!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    secureStorage = SecureStorageMock()
    storage = Storage(secureStorage: secureStorage)
  }
  
  func testSave_successfully_shouldNotThrow() {
    XCTAssertNoThrow(try storage.save(Constants.data, withKey: Constants.key), "Save should not throw")
  }
  
  func testSave_unsucessfully_shouldThrow() {
    secureStorage.error = TestError.operationFailed
    XCTAssertThrowsError(try storage.save(Constants.data, withKey: Constants.key), "Get should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testGet_valueExists_shouldReturnValue() {
    var data: Data!
    let expectedData = Constants.data
    let expectedCallsToMethod = 1
    secureStorage.operationResult = expectedData
    
    XCTAssertNoThrow(data = try storage.get(Constants.key), "Get should not throw")
    XCTAssertEqual(data, expectedData, "Returned data should be \(expectedData), but wsa \(data!)")
    XCTAssertEqual(
      secureStorage.callsToGet,
      expectedCallsToMethod,
      "Get should be called \(expectedCallsToMethod) but was called \(secureStorage.callsToGet)"
    )
  }
  
  func testGet_valueDoesNotExist_shouldThrow() {
    secureStorage.error = TestError.operationFailed
    XCTAssertThrowsError(try storage.get(Constants.key), "Get should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testGetAll_withExistingValue_shouldReturnValues() {
    var data: [Data?]!
    let expectedData = [Constants.data]
    let expectedCallsToMethod = 1
    secureStorage.objectsData = expectedData
    
    XCTAssertNoThrow(data = try storage.getAll(), "Get all should not throw")
    XCTAssertEqual(data, expectedData, "Returned data should be \(expectedData), but wsa \(data!)")
    XCTAssertEqual(
      secureStorage.callsToGetAll,
      expectedCallsToMethod,
      "Get all should be called \(expectedCallsToMethod) time but was called \(secureStorage.callsToGet) times"
    )
  }
  
  func testGetAll_withError_shouldThrow() {
    secureStorage.error = TestError.operationFailed
    XCTAssertThrowsError(try storage.getAll(), "GetAll should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
  
  func testRemoveValue_successfully_shouldNotThrow() {
    XCTAssertNoThrow(try storage.removeValue(for: Constants.key), "Remove value should not throw")
  }
  
  func testRemoveValue_unsuccessfully_shouldThrow() {
    secureStorage.error = TestError.operationFailed
    XCTAssertThrowsError(try storage.removeValue(for: Constants.key), "Remove value should throw") { error in
      XCTAssertEqual((error as! TestError), TestError.operationFailed)
    }
  }
}

private extension StorageTests {
  struct Constants {
    static let key = "key"
    static let data = "data".data(using: .utf8)!
  }
}
