//
//  KeychainMock.swift
//  TwilioSecurityTests
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

enum KeychainMethods {
  case accessControl
  case sign
  case verify
  case representation
  case generateKeyPair
  case copyItemMatching
  case addItem
  case deleteItem
}

class KeychainMock {
  var error: Error?
  var generateKeyPairError: Error?
  var verifyShouldSucceed = false
  var operationResult: Data!
  var addItemStatus: [OSStatus]!
  var deleteItemStatus: OSStatus!
  var keyPair: KeyPair!
  var keys: [AnyObject]!
  private(set) var callsToAddItem = 0
  private(set) var callOrder = [KeychainMethods]()
  private var callsToCopyItemMatching = -1
  
}

extension KeychainMock: KeychainProtocol {
  
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl {
    if let error = error {
      throw error
    }
    var error: Unmanaged<CFError>?
    guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection, flags, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    return accessControl
  }
  
  func sign(withPrivateKey key: SecKey, algorithm: SecKeyAlgorithm, dataToSign data: Data) throws -> Data {
    if let error = error {
      throw error
    }
    return operationResult
  }
  
  func verify(withPublicKey key: SecKey, algorithm: SecKeyAlgorithm, signedData: Data, signature: Data) -> Bool {
    return verifyShouldSucceed
  }
  
  func representation(forKey key: SecKey) throws -> Data {
    if let error = error {
      throw error
    }
    return operationResult
  }
  
  func generateKeyPair(withParameters parameters: [String: Any]) throws -> KeyPair {
    if let error = generateKeyPairError {
      throw error
    }
    
    return keyPair
  }
  
  func copyItemMatching(query: Query) throws -> AnyObject {
    callsToCopyItemMatching += 1
    if let error = error {
      self.error = nil
      throw error
    }

    guard keys.indices.contains(callsToCopyItemMatching) else {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(errSecItemNotFound), userInfo: [:])
    }

    return keys[callsToCopyItemMatching]
  }
  
  func addItem(withQuery query: Query) -> OSStatus {
    callsToAddItem += 1
    callOrder.append(.addItem)
    return addItemStatus[callsToAddItem - 1]
  }
  
  func deleteItem(withQuery query: Query) -> OSStatus {
    callOrder.append(.deleteItem)
    return deleteItemStatus
  }
}
