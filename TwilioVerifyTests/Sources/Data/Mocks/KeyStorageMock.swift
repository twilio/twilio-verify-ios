//
//  KeyStorageMock.swift
//  TwilioVerifyTests
//
//  Created by Santiago Avila on 6/11/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class KeyStorageMock {
  var errorCreatingKey: Error?
  var error: Error?
  var createKeyResult: String!
  var signResult: Data!
}

extension KeyStorageMock: KeyStorage {
  func createKey(withAlias alias: String) throws -> String {
    if let error = errorCreatingKey {
      throw error
    }
    return createKeyResult
  }
  
  func sign(withAlias alias: String, message: String) throws -> Data {
    if let error = error {
      throw TwilioVerifyError.keyStorageError(error: error as NSError)
    }
    return signResult
  }
  
  func signAndEncode(withAlias alias: String, message: String) throws -> String {
    do {
      return try sign(withAlias: alias, message: message).base64EncodedString()
    } catch {
      throw error
    }
  }
  
  func deleteKey(withAlias alias: String) throws {
    if let error = error {
      throw error
    }
  }
}
