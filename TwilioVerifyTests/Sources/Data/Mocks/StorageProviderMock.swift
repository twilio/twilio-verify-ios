//
//  StorageProviderMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/10/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class StorageProviderMock: StorageProvider {
  var factorData: Data?
  var expectedSid: String?
  var errorSaving: Error?
  var errorGetting: Error?
  
  func save(_ data: Data, withKey key: String) throws {
    if let error = errorSaving, key == expectedSid {
      throw error
    }
    if key != expectedSid {
      fatalError()
    }
  }
  
  func get(_ key: String) throws -> Data {
    if let error = errorGetting, expectedSid == key {
      throw error
    }
    if let factorData = factorData , expectedSid == key {
      return factorData
    }
    fatalError()
  }
  
  func removeValue(for key: String) throws {
    
  }
}
