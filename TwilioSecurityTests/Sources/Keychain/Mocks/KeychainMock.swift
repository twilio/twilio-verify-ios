//
//  KeychainMock.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioSecurity

class KeychainMock {
  var error: Error?
  var verifyShouldSucceed = false
  var operationResult: Data!
  var osStatusResult: OSStatus!
  var keyPair: KeyPair!
  var keys: [SecKey]!
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
    if let error = error {
      throw error
    }
    
    return keyPair
  }
  
  func copyItemMatching(query: Query) throws -> SecKey {
    callsToCopyItemMatching += 1
    if let error = error {
      throw error
    }
    return keys[callsToCopyItemMatching]
  }
  
  func addItem(withQuery query: Query) -> OSStatus {
    return osStatusResult
  }
  
  func deleteItem(withQuery query: Query) -> OSStatus {
    return osStatusResult
  }
}
