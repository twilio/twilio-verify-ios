//
//  KeyStorageMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

class KeyStorageMock {
  var errorCreatingKey: Error?
  var error: Error?
  var createKeyResult: String!
  var signResult: Data!
  var deletedAlias: String?
  var errorDeletingKey: Error?
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
    if let error = errorDeletingKey {
      throw error
    }
    deletedAlias = alias
  }
}
