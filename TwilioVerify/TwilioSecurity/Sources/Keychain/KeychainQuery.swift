//
//  KeychainQuery.swift
//  TwilioSecurity
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

typealias Query = [String: Any]

enum KeyAttrClass {
  case `public`
  case `private`
  
  var value: CFString {
    switch self {
      case .public:
        return kSecAttrKeyClassPublic
      case .private:
        return kSecAttrKeyClassPrivate
    }
  }
}

protocol KeychainQueryProtocol {
  func key(withTemplate template: SignerTemplate, class keyClass: KeyAttrClass) -> Query
  func saveKey(_ key: SecKey, withAlias alias: String) -> Query
  func deleteKey(withAlias alias: String) -> Query
  func save(data: Data, withKey key: String) -> Query
  func getData(withKey key: String) -> Query
  func getAll() -> Query
  func delete(withKey key: String) -> Query
  func deleteItems() -> Query
}

struct KeychainQuery: KeychainQueryProtocol {
  func key(withTemplate template: SignerTemplate, class keyClass: KeyAttrClass) -> Query {
    [kSecClass: kSecClassKey,
     kSecAttrKeyClass: keyClass.value,
     kSecAttrLabel: template.alias,
     kSecReturnRef: true,
     kSecAttrKeyType: template.algorithm,
     kSecAttrAccessControl: template.accessControl] as Query
  }
  
  func saveKey(_ key: SecKey, withAlias alias: String) -> Query {
    [kSecClass: kSecClassKey,
     kSecAttrLabel: alias,
     kSecValueRef: key,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func deleteKey(withAlias alias: String) -> Query {
    [kSecClass: kSecClassKey,
     kSecAttrLabel: alias,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func save(data: Data, withKey key: String) -> Query {
    [kSecClass: kSecClassGenericPassword,
     kSecAttrAccount: key,
     kSecValueData: data,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func getData(withKey key: String) -> Query {
    [kSecClass: kSecClassGenericPassword,
     kSecAttrAccount: key,
     kSecReturnData: true,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func getAll() -> Query {
    [kSecClass: kSecClassGenericPassword,
     kSecReturnAttributes: true,
     kSecReturnData: true,
     kSecMatchLimit: kSecMatchLimitAll,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func delete(withKey key: String) -> Query {
    [kSecClass: kSecClassGenericPassword,
     kSecAttrAccount: key,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func deleteItems() -> Query {
    [kSecClass: kSecClassGenericPassword,
    kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
}
