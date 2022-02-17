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

typealias Query = [CFString: Any]

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
  func save(data: Data, withKey key: String, withServiceName service: String?) -> Query
  func getData(withKey key: String) -> Query
  func getAll(withServiceName service: String?) -> Query
  func delete(withKey key: String) -> Query
  func deleteItems(withServiceName service: String?) -> Query
}

struct KeychainQuery: KeychainQueryProtocol {

  // MARK: - Properties

  /// Direct use of [kSecAttrAccessGroup](https://developer.apple.com/documentation/security/ksecattraccessgroup?language=swift),
  /// when set all methods will make use of it.
  var accessGroup: String?

  init(accessGroup: String?) {
    self.accessGroup = accessGroup
  }

  // MARK: - Public Methods

  func key(withTemplate template: SignerTemplate, class keyClass: KeyAttrClass) -> Query {
    properties([
      kSecClass: kSecClassKey,
      kSecAttrKeyClass: keyClass.value,
      kSecAttrLabel: template.alias,
      kSecReturnRef: true,
      kSecAttrKeyType: template.algorithm
    ])
  }

  func saveKey(_ key: SecKey, withAlias alias: String) -> Query {
    properties([
      kSecClass: kSecClassKey,
      kSecAttrLabel: alias,
      kSecValueRef: key,
      kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ])
  }
  
  func deleteKey(withAlias alias: String) -> Query {
    [
     kSecClass: kSecClassKey,
     kSecAttrLabel: alias,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ]
  }

  func save(data: Data, withKey key: String, withServiceName service: String?) -> Query {
    var query = [kSecClass: kSecClassGenericPassword,
     kSecAttrAccount: key,
     kSecValueData: data,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
    if let service = service {
      query[kSecAttrService] = service
    }
    return properties(query)
  }

  func getData(withKey key: String) -> Query {
    properties([
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: key,
      kSecReturnData: true,
      kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ])
  }

  func getAll(withServiceName service: String?) -> Query {
    var query = [kSecClass: kSecClassGenericPassword,
     kSecReturnAttributes: true,
     kSecReturnData: true,
     kSecMatchLimit: kSecMatchLimitAll,
     kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly] as Query
    if let service = service {
      query[kSecAttrService] = service
    }
    return properties(query)
  }

  func delete(withKey key: String) -> Query {
    [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: key
    ]
  }

  func deleteItems(withServiceName service: String?) -> Query {
    var query = [kSecClass: kSecClassGenericPassword] as Query
    if let service = service {
      query[kSecAttrService] = service
    }
    return query
  }

  // MARK: - Private Methods

  func properties(_ properties: Query) -> Query {
    var customProperties = properties

    if let accessGroup = accessGroup {
      customProperties[kSecAttrAccessGroup] = accessGroup
    }

    return customProperties
  }
}
