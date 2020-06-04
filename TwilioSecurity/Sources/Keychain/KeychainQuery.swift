//
//  KeychainQuery.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 6/1/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

typealias Query = [String: Any]

enum KeyClass {
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
  func key(withTemplate template: SignerTemplate, class keyClass: KeyClass) -> Query
  func saveKey(_ key: SecKey, withAlias alias: String) -> Query
  func save(data: Data, withKey key: String) -> Query
  func getData(withKey key: String) -> Query
}

struct KeychainQuery: KeychainQueryProtocol {
  func key(withTemplate template: SignerTemplate, class keyClass: KeyClass) -> Query {
    return [kSecClass: kSecClassKey,
            kSecAttrKeyClass: keyClass.value,
            kSecAttrLabel: template.alias,
            kSecReturnRef: true,
            kSecAttrKeyType: template.algorithm,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func saveKey(_ key: SecKey, withAlias alias: String) -> Query {
    return [kSecClass: kSecClassKey,
            kSecAttrLabel: alias,
            kSecValueRef: key,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func save(data: Data, withKey key: String) -> Query {
    return [kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
  
  func getData(withKey key: String) -> Query {
    return [kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
  }
}
