//
//  KeychainManagerMock.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class KeyManagerSecurityMock {
  
  var error: Error?
  var signerKeyPair: KeyPair!
  private let keychain: KeychainProtocol
  
  required init(withKeychain keychain: KeychainProtocol = KeychainMock(),
                keychainQuery: KeychainQueryProtocol = KeychainQuery()) {
    self.keychain = keychain
  }
}

extension KeyManagerSecurityMock: KeyManagerProtocol {
  func signer(withTemplate template: SignerTemplate) throws -> Signer {
    return ECSigner(withKeyPair: signerKeyPair, signatureAlgorithm: template.signatureAlgorithm)
  }
  
  func deleteKey(withAlias alias: String) throws {
    if let error = error {
      throw error
    }
  }
}
