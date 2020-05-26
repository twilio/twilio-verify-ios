//
//  KeyManager.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol KeyManagerProtocol {
  init(withKeychain keychain: KeychainProtocol)
}

class KeyManager {
  
  private let keychain: KeychainProtocol
  
  required init(withKeychain keychain: KeychainProtocol = Keychain()) {
    self.keychain = keychain
  }
}

extension KeyManager: KeyManagerProtocol {

}
