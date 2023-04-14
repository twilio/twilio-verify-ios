//
//  KeychainManagerMock.swift
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

class KeyManagerSecurityMock {
  
  var error: Error?
  var signerKeyPair: KeyPair!
  private let keychain: KeychainProtocol
  
  required init(
    withKeychain keychain: KeychainProtocol = KeychainMock(),
    keychainQuery: KeychainQueryProtocol = KeychainQuery(accessGroup: nil, attrAccessible: .afterFirstUnlockThisDeviceOnly)
  ) {
    self.keychain = keychain
  }
}

extension KeyManagerSecurityMock: KeyManagerProtocol {
  func signer(withTemplate template: SignerTemplate) throws -> Signer {
    return ECSigner(withKeyPair: signerKeyPair, signatureAlgorithm: template.signatureAlgorithm, keychain: keychain)
  }
  
  func deleteKey(withAlias alias: String) throws {
    if let error = error {
      throw error
    }
  }
}
