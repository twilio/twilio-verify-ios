//
//  KeyManager.swift
//  TwilioSecurity
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

///:nodoc:
public protocol KeyManagerProtocol {
  func signer(withTemplate template: SignerTemplate) throws -> Signer
  func deleteKey(withAlias alias: String) throws
}

///:nodoc:
public class KeyManager {
  
  private let keychain: KeychainProtocol
  private let keychainQuery: KeychainQueryProtocol
  
  public convenience init() {
    self.init(withKeychain: Keychain(), keychainQuery: KeychainQuery())
  }
  
  init(withKeychain keychain: KeychainProtocol = Keychain(),
       keychainQuery: KeychainQueryProtocol = KeychainQuery()) {
    self.keychain = keychain
    self.keychainQuery = keychainQuery
  }
  
  func keyPair(forTemplate template: SignerTemplate) throws -> KeyPair {
    do {
      let publicKey = try key(withQuery: keychainQuery.key(withTemplate: template, class: .public))
      let privateKey = try key(withQuery: keychainQuery.key(withTemplate: template, class: .private))
      return KeyPair(publicKey: publicKey, privateKey: privateKey)
    } catch {
      throw error
    }
  }
  
  func generateKeyPair(withTemplate template: SignerTemplate) throws -> KeyPair {
    do {
      let keyPair = try keychain.generateKeyPair(withParameters: template.parameters)
      return keyPair
    } catch {
      throw error
    }
  }

  func key(withQuery query: Query) throws -> SecKey {
    do {
      let key = try keychain.copyItemMatching(query: query)
      // swiftlint:disable:next force_cast
      return key as! SecKey
    } catch {
      throw error
    }
  }
  
  func forceSavePublicKey(_ key: SecKey, withAlias alias: String) throws {
    let query = keychainQuery.saveKey(key, withAlias: alias)
    var status = keychain.addItem(withQuery: query)
    if status == errSecDuplicateItem {
      status = keychain.deleteItem(withQuery: query)
      status = keychain.addItem(withQuery: query)
    }
    
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      throw error
    }
  }
}

extension KeyManager: KeyManagerProtocol {
  public func signer(withTemplate template: SignerTemplate) throws -> Signer {
    var keyPair: KeyPair!
    do {
      keyPair = try self.keyPair(forTemplate: template)
    } catch let error {
      if template.shouldExist {
        throw error
      }
      do {
        keyPair = try generateKeyPair(withTemplate: template)
        try forceSavePublicKey(keyPair.publicKey, withAlias: template.alias)
      } catch {
        throw error
      }
    }
    return ECSigner(withKeyPair: keyPair, signatureAlgorithm: template.signatureAlgorithm)
  }
  
  public func deleteKey(withAlias alias: String) throws {    
    let status = keychain.deleteItem(withQuery: keychainQuery.deleteKey(withAlias: alias))
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      throw error
    }
  }
}
