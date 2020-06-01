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
  func signer(withTemplate: SignerTemplate) throws -> Signer
}

class KeyManager {
  
  typealias Query = [String: Any]
  private let keychain: KeychainProtocol
  
  required init(withKeychain keychain: KeychainProtocol = Keychain()) {
    self.keychain = keychain
  }
  
  func getKeyPair(forTemplate template: SignerTemplate) throws -> KeyPair {
    do {
      let publicKey = try key(withQuery: keyQuery(withTemplate: template, class: kSecAttrKeyClassPublic))
      let privateKey = try key(withQuery: keyQuery(withTemplate: template, class: kSecAttrKeyClassPrivate))
      return (publicKey: publicKey, privateKey: privateKey)
    } catch let error {
      throw error
    }
  }

  func key(withQuery query: Query) throws -> SecKey {
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess, let key = result else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      throw error
    }
    return key as! SecKey
  }
  
  func keyQuery(withTemplate template: SignerTemplate, class keyClass: CFString) -> Query {
    return [kSecClass: kSecClassKey,
            kSecAttrKeyClass: keyClass,
            kSecAttrLabel: template.alias,
            kSecReturnRef: true,
            kSecAttrKeyType: template.algorithm] as Query
  }
}

extension KeyManager: KeyManagerProtocol {
  func signer(withTemplate: SignerTemplate) throws -> Signer {
    
  }
}
