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
  func updateItem(withQuery query: Query, attributes: CFDictionary) -> OSStatus
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
  let accessGroup: String?

  init(accessGroup: String?) {
    self.accessGroup = accessGroup
  }

  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl {
    var keychainError: Unmanaged<CFError>?
    
    guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection, flags, &keychainError) else {
      var error: KeychainError = .unexpectedError

      if let accessControlError = (keychainError?.takeRetainedValue() as? Error) {
        error = .errorCreatingAccessControl(cause: accessControlError)
      }
      
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      
      throw error
    }
    
    return accessControl
  }
  
  func sign(withPrivateKey key: SecKey, algorithm: SecKeyAlgorithm, dataToSign data: Data) throws -> Data {
    var keychainError: Unmanaged<CFError>?

    let signature: CFData? = retry {
      SecKeyCreateSignature(key, algorithm, data as CFData, &keychainError)
    } validation: { signature in
      signature != nil
    }

    guard let signature = signature else {
      var error: KeychainError = .unexpectedError
  
      if let createSignatureError = (keychainError?.takeRetainedValue() as? Error) {
        error = .createSignatureError(cause: createSignatureError)
      }
      
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
      let error = (keychainError?.takeRetainedValue() as? Error) ?? KeychainError.unexpectedError
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
    return representation as Data
  }
  
  func generateKeyPair(withParameters parameters: [String: Any]) throws -> KeyPair {
    var publicKey, privateKey: SecKey?
    let parameters = addAccessGroupToKeyPairs(parameters: parameters)
    let status = SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)

    guard status == errSecSuccess else {
      let error: KeychainError = .invalidStatusCode(code: Int(status))
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }

    guard let publicKey = publicKey else {
      let error: KeychainError = .unableToGeneratePublicKey
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }

    guard let privateKey = privateKey else {
      let error: KeychainError = .unableToGeneratePrivateKey
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }

    Logger.shared.log(
      withLevel: .debug,
      message: "Generated key pair for parameters \(parameters)"
    )

    return KeyPair(
      publicKey: publicKey,
      privateKey: privateKey
    )
  }
  
  func copyItemMatching(query: Query) throws -> AnyObject {
    var result: AnyObject?

    let status: OSStatus = retry {
      SecItemCopyMatching(query as CFDictionary, &result)
    } validation: { status in
      status == errSecSuccess
    }

    guard status == errSecSuccess else {
      let error: KeychainError = .invalidStatusCode(code: Int(status))
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }

    guard let result = result else {
      let error: KeychainError = .unableToCopyItem
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

  func updateItem(withQuery query: Query, attributes: CFDictionary) -> OSStatus {
    Logger.shared.log(withLevel: .debug, message: "Update item for \(query)")
    return SecItemUpdate(query as CFDictionary, attributes)
  }
  
  @discardableResult
  func deleteItem(withQuery query: Query) -> OSStatus {
    Logger.shared.log(withLevel: .debug, message: "Deleted item for \(query)")
    return SecItemDelete(query as CFDictionary)
  }

  func addAccessGroupToKeyPairs(parameters: [String: Any]) -> CFDictionary {
    var customParameters = parameters as Query

    guard
      var privateParameters = customParameters[kSecPrivateKeyAttrs] as? Query,
      var publicParameters = customParameters[kSecPublicKeyAttrs] as? Query,
      let accessControl = try? accessControl(
        withProtection: Constants.accessControlProtection,
        flags: Constants.accessControlFlags
      )
    else {
      return parameters as CFDictionary
    }

    privateParameters[kSecAttrAccessControl] = accessControl
    publicParameters[kSecAttrAccessControl] = accessControl

    if let accessGroup = accessGroup {
      privateParameters[kSecAttrAccessGroup] = accessGroup
      publicParameters[kSecAttrAccessGroup] = accessGroup
    }

    customParameters[kSecPrivateKeyAttrs] = privateParameters
    customParameters[kSecPublicKeyAttrs] = publicParameters

    return customParameters as CFDictionary
  }

  private func retry<T>(
    tries: Int = 2,
    block: () -> T,
    delay: TimeInterval = 0.1,
    validation: ((T) -> Bool)? = nil
  ) -> T {
    var tries: Int = tries
    repeat {
      tries -= 1
      let result = block()
      if let validation = validation {
        if validation(result) {
          return result
        } else {
          Thread.sleep(forTimeInterval: delay)
          break
        }
      } else {
        return result
      }
    } while tries > 0

    return block()
  }

  enum Constants {
    static let accessControlProtection = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    static let accessControlFlags: SecAccessControlCreateFlags = .privateKeyUsage
  }
}
