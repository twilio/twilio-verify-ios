//
//  Keychain.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol KeychainProtocol {
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl
  func sign(withPrivateKey key: SecKey, algorithm: SecKeyAlgorithm, dataToSign data: Data) throws -> Data
  func verify(withPublicKey key: SecKey, algorithm: SecKeyAlgorithm, signedData: Data, signature: Data) -> Bool
  func representation(forKey key: SecKey) throws -> Data
  func generateKeyPair(withParameters parameters: [String: Any]) throws -> KeyPair
  func copyItemMatching(query: Query) throws -> SecKey
  func addItem(withQuery query: Query) -> OSStatus
  func deleteItem(withQuery query: Query) -> OSStatus
}

extension KeychainProtocol {
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags = []) throws -> SecAccessControl {
    do {
      return try accessControl(withProtection: protection, flags: flags)
    } catch {
      throw error
    }
  }
}

class Keychain: KeychainProtocol {
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl {
    var error: Unmanaged<CFError>?
    guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection, flags, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    return accessControl
  }
  
  func sign(withPrivateKey key: SecKey, algorithm: SecKeyAlgorithm, dataToSign data: Data) throws -> Data {
    var error: Unmanaged<CFError>?
    guard let signature = SecKeyCreateSignature(key, algorithm, data as CFData, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    
    return signature as Data
  }
  
  func verify(withPublicKey key: SecKey, algorithm: SecKeyAlgorithm, signedData: Data, signature: Data) -> Bool {
    var error: Unmanaged<CFError>?
    return SecKeyVerifySignature(key, algorithm, signedData as CFData, signature as CFData, &error)
  }
  
  func representation(forKey key: SecKey) throws -> Data {
    var error: Unmanaged<CFError>?
    guard let representation = SecKeyCopyExternalRepresentation(key, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    return representation as Data
  }
  
  func generateKeyPair(withParameters parameters: [String : Any]) throws -> KeyPair {
    var publicKey, privateKey: SecKey?
    let status = SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      throw error
    }
    
    return KeyPair(publicKey: publicKey!, privateKey: privateKey!)
  }
  
  func copyItemMatching(query: Query) throws -> SecKey {
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess, let key = result else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      throw error
    }
    return key as! SecKey
  }
  
  func addItem(withQuery query: Query) -> OSStatus {
    return SecItemAdd(query as CFDictionary, nil)
  }
  
  func deleteItem(withQuery query: Query) -> OSStatus {
    return SecItemDelete(query as CFDictionary)
  }
}

