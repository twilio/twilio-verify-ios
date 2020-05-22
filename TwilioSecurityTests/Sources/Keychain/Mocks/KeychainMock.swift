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
  var operationResult: Data?
}

extension KeychainMock: KeychainProtocol {
  func accessControl(withProtection protcetion: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl {
    if let error = error {
      throw error
    }
    //TODO: @sfierro will work on this, (returning this will crash the tests)
    return SecAccessControl.self as! SecAccessControl
  }
  
  func sign(withPrivateKey key: SecKey, algorithm: SecKeyAlgorithm, dataToSign data: Data) throws -> Data {
    if let error = error {
      throw error
    }
    return operationResult!
  }
  
  func verify(withPublicKey key: SecKey, algorithm: SecKeyAlgorithm, signedData: Data, signature: Data) -> Bool {
    return verifyShouldSucceed
  }
  
  func representation(forKey key: SecKey) throws -> Data {
    if let error = error {
      throw error
    }
    return operationResult!
  }
}
