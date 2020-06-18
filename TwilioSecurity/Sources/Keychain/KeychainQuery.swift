//
//  KeychainQuery.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 6/1/20.
//  Copyright © 2020 Twilio. All rights reserved.
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

enum KeyClass {
  case genericPassword
  case key
  
  var value: CFString {
    switch self {
      case .genericPassword:
        return kSecClassGenericPassword
      case .key:
        return kSecClassKey
    }
  }
}

protocol KeychainQueryProtocol {
  func key(withTemplate template: SignerTemplate, class keyClass: KeyAttrClass) -> Query
  func saveKey(_ key: SecKey, withAlias alias: String) -> Query
  func save(data: Data, withKey key: String) -> Query
  func getData(withKey key: String) -> Query
  func delete(withKey key: String, class: KeyClass) -> Query
}

struct KeychainQuery: KeychainQueryProtocol {
  func key(withTemplate template: SignerTemplate, class keyClass: KeyAttrClass) -> Query {
    [kSecClass: kSecClassKey,
     kSecAttrKeyClass: keyClass.value,
     kSecAttrLabel: template.alias,
     kSecReturnRef: true,
     kSecAttrKeyType: template.algorithm,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func saveKey(_ key: SecKey, withAlias alias: String) -> Query {
    [kSecClass: kSecClassKey,
     kSecAttrLabel: alias,
     kSecValueRef: key,
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
  
  func delete(withKey key: String, class keyClass: KeyClass) -> Query {
    [kSecClass: keyClass.value,
    kSecAttrAccount: key,
    kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
}
