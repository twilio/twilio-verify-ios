//
//  KeyPairFactory.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioSecurity

struct KeyPairFactory {
  static func createKeyPair() throws -> KeyPair {
    var publicKeySec, privateKeySec: SecKey!
    let status = SecKeyGeneratePair(Constants.pairAttributes, &publicKeySec, &privateKeySec)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      throw error
    }
    return KeyPair(publicKey: publicKeySec, privateKey: privateKeySec)
  }
  
  static func keyPairParameters() -> [String: Any] {
    return Constants.pairAttributes as! [String: Any]
  }
}

private extension KeyPairFactory {
  struct Constants {
   static let applicationTag = "com.security.tests"
    static let publicTag = "public"
    static let privateTag = "private"
    static let privateAttributes = [kSecAttrApplicationTag: Constants.applicationTag + Constants.privateTag] as [String: Any]
    static let publicAttributes = [kSecAttrApplicationTag: Constants.applicationTag + Constants.publicTag] as [String : Any]
    static let pairAttributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                                 kSecAttrKeySizeInBits: 256,
                                 kSecPublicKeyAttrs: publicAttributes,
                                 kSecPrivateKeyAttrs: privateAttributes] as CFDictionary
  }
}
