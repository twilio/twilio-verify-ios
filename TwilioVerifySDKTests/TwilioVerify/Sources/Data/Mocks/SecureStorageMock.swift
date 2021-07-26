//
//  SecureStorageMock.swift
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
@testable import TwilioVerifySDK

class SecureStorageMock {
  var error: Error?
  var operationResult: Data!
  var objectsData: [Data]!
  private(set) var callsToSave = 0
  private(set) var callsToGet = 0
  private(set) var callsToRemoveValue = 0
  private(set) var callsToGetAll = 0
  private(set) var callsToClear = 0
}

extension SecureStorageMock: SecureStorageProvider {
  func save(_ data: Data, withKey key: String) throws {
    callsToSave += 1
    if let error = error {
      throw error
    }
  }
  
  func get(_ key: String) throws -> Data {
    callsToGet += 1
    if let error = error {
      throw error
    }
    return operationResult
  }
  
  func getAll() throws -> [Data] {
    callsToGetAll += 1
    if let error = error {
      throw error
    }
    return objectsData
  }
  
  func removeValue(for key: String) throws {
    callsToRemoveValue += 1
    if let error = error {
      throw error
    }
  }
  
  func clear() throws {
    callsToClear += 1
    if let error = error {
      throw error
    }
  }
}
