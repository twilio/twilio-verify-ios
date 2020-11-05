//
//  StorageProviderMock.swift
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
