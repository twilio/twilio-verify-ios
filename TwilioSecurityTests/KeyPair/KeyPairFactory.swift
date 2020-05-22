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
  static func createKeyPair() -> KeyPair {
    var publicKeySec, privateKeySec: SecKey?
    SecKeyGeneratePair(Constants.pairAttributes, &publicKeySec, &privateKeySec)
    let keyPair = (publicKey: publicKeySec!, privateKey: privateKeySec!)
    return keyPair
  }
}

private extension KeyPairFactory {
  struct Constants {
    static let pairAttributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                                 kSecAttrKeySizeInBits: 256] as CFDictionary
  }
}
