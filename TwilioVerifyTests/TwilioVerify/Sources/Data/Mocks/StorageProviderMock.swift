//
//  StorageProviderMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//
import Foundation
@testable import TwilioVerify

class StorageProviderMock {
  var factorData: Data?
  var factorsData: [Data]!
  var expectedSid: String?
  var errorSaving: Error?
  var errorGetting: Error?
  var errorGettingAll: Error?
  var errorRemoving: Error?
  var removedKey: String?
}

extension StorageProviderMock: StorageProvider {
  var version: Int {
    1
  }
  
  func save(_ data: Data, withKey key: String) throws {
    if let error = errorSaving, key == expectedSid {
      throw error
    }
    if key != expectedSid {
      fatalError("Key should be \(expectedSid!)")
    }
  }
  
  func get(_ key: String) throws -> Data {
    if let error = errorGetting, expectedSid == key {
      throw error
    }
    if let factorData = factorData, expectedSid == key {
      return factorData
    }
    fatalError("Expected params not set")
  }
  
  func getAll() throws -> [Data] {
    if let error = errorGettingAll {
      throw error
    }
    return factorsData
  }
  
  func removeValue(for key: String) throws {
    if let error = errorRemoving, key == expectedSid {
      throw error
    }
    removedKey = key
  }
}
