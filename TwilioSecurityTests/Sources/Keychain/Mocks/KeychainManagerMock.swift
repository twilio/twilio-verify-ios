//
//  KeychainManagerMock.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioSecurity

class KeychainManagerMock {
  
  var accessControlError: Error?
  private let keychain: KeychainProtocol
  
  required init(withKeychain keychain: KeychainProtocol = KeychainMock()) {
    self.keychain = keychain
  }
}

extension KeychainManagerMock: KeychainManagerProtocol {
 
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl {
    if let error = accessControlError {
      throw error
    }
    
    return try! keychain.accessControl(withProtection: protection, flags: flags)
  }
}
