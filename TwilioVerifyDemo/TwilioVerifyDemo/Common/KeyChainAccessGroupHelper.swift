//
//  KeyStorage - Simplifying securely saving key information
//
//  KeyChainAccessGroupHelper.swift
//  Created by Ben Bahrenburg on 12/30/16.
//  Copyright © 2017 bencoding.com. All rights reserved.
//

import Foundation
import Security

struct KeyChainAccessGroupInfo {
  var prefix: String
  var keyChainGroup: String
  var rawValue: String
}

class KeyChainAccessGroupHelper {

  class func getAccessGroupInfo() -> KeyChainAccessGroupInfo? {
    let query: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: "detectAppIdentifierForKeyChainGroupIdUsage",
      kSecAttrAccessible: kSecAttrAccessibleAlwaysThisDeviceOnly,
      kSecReturnAttributes: kCFBooleanTrue as Any
    ]

    var dataTypeRef: AnyObject?
    var status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }

    if status == errSecItemNotFound {
      let createStatus = SecItemAdd(query as CFDictionary, nil)
      guard createStatus == errSecSuccess else { return nil }
      status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
    }

    guard status == errSecSuccess else { return nil }

    let accessGroup = ((dataTypeRef as? [AnyHashable: Any])?[(kSecAttrAccessGroup as String)] as? String)

    if let accessGroup = accessGroup, accessGroup.components(separatedBy: ".").count > 0 {
      let components = accessGroup.components(separatedBy: ".")
      let prefix = components.first ?? .init()
      let elements = components.filter { $0 != prefix }
      let keyChainGroup = elements.joined(separator: ".")

      return KeyChainAccessGroupInfo(prefix: prefix, keyChainGroup: keyChainGroup, rawValue: accessGroup)
    }

    return nil
  }
}
