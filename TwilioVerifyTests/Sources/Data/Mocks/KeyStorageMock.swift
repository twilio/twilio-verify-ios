//
//  KeyStorageAdapterMock.swift
//  TwilioVerifyTests
//
//  Created by Yeimi Moreno on 6/12/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

@testable import TwilioVerify

class KeyStorageMock {
  var error: Error?
  var operationresult: Data!
  var encodedOperationresult: String!
  var verifyShouldSucceed = false
}

extension KeyStorageMock: KeyStorage {
  func createKey(withAlias alias: String) throws -> String {
    if let error = error {
      throw error
    }
    return encodedOperationresult
  }
  
  func sign(withAlias alias: String, message: String) throws -> Data {
    if let error = error {
      throw error
    }
    return operationresult
  }
  
  func signAndEncode(withAlias alias: String, message: String) throws -> String {
    if let error = error {
      throw error
    }
    return encodedOperationresult
  }
  
  func deleteKey(withAlias alias: String) throws {
    if let error = error {
      throw error
    }
  }
}
