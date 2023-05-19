//
//  KeyStorageMock.swift
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
      throw TwilioVerifyError.keyStorageError(error: error)
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
