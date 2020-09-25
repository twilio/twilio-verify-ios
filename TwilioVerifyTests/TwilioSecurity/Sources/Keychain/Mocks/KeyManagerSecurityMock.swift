//
//  KeychainManagerMock.swift
//  TwilioSecurityTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
