//
//  Keychain.swift
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

protocol KeychainProtocol {
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl
  func sign(withPrivateKey key: SecKey, algorithm: SecKeyAlgorithm, dataToSign data: Data) throws -> Data
  func verify(withPublicKey key: SecKey, algorithm: SecKeyAlgorithm, signedData: Data, signature: Data) -> Bool
  func representation(forKey key: SecKey) throws -> Data
  func generateKeyPair(withParameters parameters: [String: Any]) throws -> KeyPair
  func copyItemMatching(query: Query) throws -> AnyObject
  func addItem(withQuery query: Query) -> OSStatus
  @discardableResult func deleteItem(withQuery query: Query) -> OSStatus
}

extension KeychainProtocol {
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags = []) throws -> SecAccessControl {
    do {
      return try accessControl(withProtection: protection, flags: flags)
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }
}

class Keychain: KeychainProtocol {
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl {
    var keychainError: Unmanaged<CFError>?
    guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection, flags, &keychainError) else {
      let error = keychainError!.takeRetainedValue() as Error
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
    return accessControl
  }
  
  func sign(withPrivateKey key: SecKey, algorithm: SecKeyAlgorithm, dataToSign data: Data) throws -> Data {
    var keychainError: Unmanaged<CFError>?
    guard let signature = SecKeyCreateSignature(key, algorithm, data as CFData, &keychainError) else {
      let error = keychainError!.takeRetainedValue() as Error
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
    Logger.shared.log(withLevel: .debug, message: "Sign data with \(algorithm)")
    return signature as Data
  }
  
  func verify(withPublicKey key: SecKey, algorithm: SecKeyAlgorithm, signedData: Data, signature: Data) -> Bool {
    var error: Unmanaged<CFError>?
    Logger.shared.log(withLevel: .debug, message: "Verify message with \(algorithm)")
    return SecKeyVerifySignature(key, algorithm, signedData as CFData, signature as CFData, &error)
  }
  
  func representation(forKey key: SecKey) throws -> Data {
    var keychainError: Unmanaged<CFError>?
    guard let representation = SecKeyCopyExternalRepresentation(key, &keychainError) else {
      let error = keychainError!.takeRetainedValue() as Error
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
    return representation as Data
  }
  
  func generateKeyPair(withParameters parameters: [String: Any]) throws -> KeyPair {
    var publicKey, privateKey: SecKey?
    let status = SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
    Logger.shared.log(withLevel: .debug, message: "Generated key pair for parameters \(parameters)")
    return KeyPair(publicKey: publicKey!, privateKey: privateKey!)
  }
  
  func copyItemMatching(query: Query) throws -> AnyObject {
    var result: AnyObject!
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
    return result
  }
  
  func addItem(withQuery query: Query) -> OSStatus {
    deleteItem(withQuery: query)
    Logger.shared.log(withLevel: .debug, message: "Added item for \(query)")
    return SecItemAdd(query as CFDictionary, nil)
  }
  
  @discardableResult
  func deleteItem(withQuery query: Query) -> OSStatus {
    Logger.shared.log(withLevel: .debug, message: "Deleted item for \(query)")
    return SecItemDelete(query as CFDictionary)
  }
}
