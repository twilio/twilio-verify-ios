//
//  ECP256.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 5/18/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public struct ECP256SignerTemplate {
  public var alias: String
  public var shouldExist: Bool
  public var parameters: [String: Any]
  public var algorithm = kSecAttrKeyTypeECSECPrimeRandom as String
  public var signatureAlgorithm = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256
  public var accessControl: SecAccessControl
  
  public init(withAlias alias: String, shouldExist: Bool) throws {
    try self.init(withAlias: alias, shouldExist: shouldExist, keychain: Keychain())
  }
}

extension ECP256SignerTemplate: SignerTemplate {
  init(withAlias alias: String, shouldExist: Bool, keychain: KeychainProtocol = Keychain()) throws {
    self.alias = alias
    self.shouldExist = shouldExist
    self.parameters = [:]
    do {
      self.accessControl = try keychain.accessControl(withProtection: Constants.accessControlProtection, flags: Constants.accessControlFlags)
      self.parameters = try createSignerParameters(keychain)
    } catch {
      throw error
    }
  }
}

extension ECP256SignerTemplate {
  func createSignerParameters(_ keychain: KeychainProtocol) throws -> [String: Any] {
    let privateParameters = [kSecAttrLabel: alias,
                             kSecAttrIsPermanent: true,
                             kSecAttrAccessControl: accessControl] as [String: Any]
    let publicParameters = [kSecAttrLabel: alias,
                            kSecAttrAccessControl: accessControl] as [String: Any]
    let parameters = [kSecAttrKeyType: algorithm,
                      kSecPrivateKeyAttrs: privateParameters,
                      kSecPublicKeyAttrs: publicParameters,
                      kSecAttrKeySizeInBits: Constants.keySize,
                      kSecAttrTokenID: kSecAttrTokenIDSecureEnclave] as [String: Any]
    return parameters
  }
  
  struct Constants {
    static let keySize = 256
    static let accessControlProtection = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    static let accessControlFlags: SecAccessControlCreateFlags = .privateKeyUsage
  }
}
