//
//  SecureStorageMock.swift
//  TwilioVerifyTests
//
//  Created by Santiago Avila on 6/9/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

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
