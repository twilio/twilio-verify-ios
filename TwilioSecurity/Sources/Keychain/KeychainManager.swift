//
//  KeychainManager.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol KeychainManagerProtocol {
  init(withKeychain keychain: KeychainProtocol)
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl
}

extension KeychainManagerProtocol {
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags = []) throws -> SecAccessControl {
    do {
      return try accessControl(withProtection: protection, flags: flags)
    } catch let error {
      throw error
    }
  }
}

class KeychainManager {
  
  private let keychain: KeychainProtocol
  
  required init(withKeychain keychain: KeychainProtocol = Keychain()) {
    self.keychain = keychain
  }
}

extension KeychainManager: KeychainManagerProtocol {
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl {
    do {
      return try keychain.accessControl(withProtection: protection, flags: flags)
    } catch let error {
      throw error
    }
  }
}
