//
//  StorageProviderMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/10/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class StorageProviderMock {
  var factorData: Data?
  var expectedSid: String?
  var errorSaving: Error?
  var errorGetting: Error?
}

extension StorageProviderMock: StorageProvider {
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
  
  func removeValue(for key: String) throws {
    
  }
}
