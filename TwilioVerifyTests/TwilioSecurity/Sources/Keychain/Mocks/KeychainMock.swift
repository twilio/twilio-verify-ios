//
//  KeychainMock.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

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
  
  func generateKeyPair(withParameters parameters: [String : Any]) throws -> KeyPair {
    if let error = generateKeyPairError {
      throw error
    }
    
    return keyPair
  }
  
  func copyItemMatching(query: Query) throws -> AnyObject {
    callsToCopyItemMatching += 1
    if let error = error {
      throw error
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
