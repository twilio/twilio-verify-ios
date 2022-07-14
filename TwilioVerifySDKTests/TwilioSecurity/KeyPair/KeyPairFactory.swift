//
//  KeyPairFactory.swift
//  TwilioSecurityTests
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
@testable import TwilioVerifySDK

// swiftlint:disable force_cast
struct KeyPairFactory {
  static func createKeyPair() throws -> KeyPair {
    var publicKeySec, privateKeySec: SecKey!
    let status = SecKeyGeneratePair(Constants.pairAttributes, &publicKeySec, &privateKeySec)
    guard status == errSecSuccess else {
      let error: KeyManagerError = .invalidStatusCode(code: Int(status))
      throw error
    }
    return KeyPair(publicKey: publicKeySec, privateKey: privateKeySec)
  }
  
  static func keyPairParameters() -> [String: Any] {
    Constants.pairAttributes as! [String: Any]
  }
}

private extension KeyPairFactory {
  struct Constants {
   static let applicationTag = "com.security.tests"
    static let publicTag = "public"
    static let privateTag = "private"
    static let privateAttributes = [kSecAttrApplicationTag: Constants.applicationTag + Constants.privateTag] as [String: Any]
    static let publicAttributes = [kSecAttrApplicationTag: Constants.applicationTag + Constants.publicTag] as [String: Any]
    static let pairAttributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                                 kSecAttrKeySizeInBits: 256,
                                 kSecPublicKeyAttrs: publicAttributes,
                                 kSecPrivateKeyAttrs: privateAttributes] as CFDictionary
  }
}
