//
//  KeychainQuery.swift
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
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
     kSecAttrAccessGroup: "9EVH78F4V4.com.twilio.TwilioVerifyDemo",
     kSecAttrSynchronizable: true] as Query
  }
  
  func getData(withKey key: String) -> Query {
    [kSecClass: kSecClassGenericPassword,
     kSecAttrAccount: key,
     kSecReturnData: true,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
     kSecAttrAccessGroup: "9EVH78F4V4.com.twilio.TwilioVerifyDemo",
     kSecAttrSynchronizable: true] as Query
  }
  
  func getAll() -> Query {
    [kSecClass: kSecClassGenericPassword,
     kSecReturnAttributes: true,
     kSecReturnData: true,
     kSecMatchLimit: kSecMatchLimitAll,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
     kSecAttrAccessGroup: "9EVH78F4V4.com.twilio.TwilioVerifyDemo",
     kSecAttrSynchronizable: true] as Query
  }
  
  func delete(withKey key: String) -> Query {
    [kSecClass: kSecClassGenericPassword,
     kSecAttrAccount: key,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
     kSecAttrAccessGroup: "9EVH78F4V4.com.twilio.TwilioVerifyDemo",
     kSecAttrSynchronizable: true] as Query
  }
  
  func deleteItems() -> Query {
    [kSecClass: kSecClassGenericPassword,
    kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    kSecAttrAccessGroup: "9EVH78F4V4.com.twilio.TwilioVerifyDemo",
    kSecAttrSynchronizable: true] as Query
  }
}
