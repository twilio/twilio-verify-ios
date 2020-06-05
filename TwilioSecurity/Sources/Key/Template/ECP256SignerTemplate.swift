//
//  ECP256.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 5/18/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct ECP256SignerTemplate {
  var alias: String
  var shouldExist: Bool
  var parameters: [String: Any]
  var algorithm = kSecAttrKeyTypeECSECPrimeRandom as String
  var signatureAlgorithm = SecKeyAlgorithm.ecdsaSignatureDigestX962SHA256
}

extension ECP256SignerTemplate: SignerTemplate {
  init(withAlias alias: String, shouldExist: Bool, keychain: KeychainProtocol = Keychain()) throws {
    self.alias = alias
    self.shouldExist = shouldExist
    self.parameters = [:]
    do {
      self.parameters = try createSignerParameters(keychain)
    } catch {
      throw error
    }
  }
  
  func createSignerParameters(_ keychain: KeychainProtocol) throws -> [String: Any] {
    do {
      let privateParameters = [kSecAttrLabel: alias,
                               kSecAttrIsPermanent: true,
                               kSecAttrAccessible: Constants.accessControlProtection] as [String: Any]
      let publicParameters = [kSecAttrLabel: alias,
                              kSecAttrAccessControl: try keychain.accessControl(withProtection: Constants.accessControlProtection)] as [String: Any]
      let parameters = [kSecAttrKeyType: algorithm,
                        kSecPrivateKeyAttrs: privateParameters,
                        kSecPublicKeyAttrs: publicParameters,
                        kSecAttrKeySizeInBits: Constants.keySize,
                        kSecAttrTokenID: kSecAttrTokenIDSecureEnclave] as [String: Any]
      return parameters
    } catch {
      throw error
    }
  }
}

extension ECP256SignerTemplate {
  struct Constants {
    static let keySize = 256
    static let accessControlProtection = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
  }
}
