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
  init(withAlias alias: String, shouldExist: Bool) throws {
    self.alias = alias
    self.shouldExist = shouldExist
    self.parameters = [:]
    do {
      self.parameters = try createSignerParameters()
    } catch let error {
      throw(error)
    }
  }
  
  func createSignerParameters() throws -> [String: Any] {
    do {
      let privateParameters = [kSecAttrLabel: alias,
                               kSecAttrIsPermanent: true,
                               kSecAttrAccessible: Constants.accessControlProtection] as [String: Any]
      let publicParameters = [kSecAttrLabel: alias,
                              kSecAttrAccessControl: try accessControl(withProtection: Constants.accessControlProtection)] as [String: Any]
      let parameters = [kSecAttrKeyType: algorithm,
                        kSecPrivateKeyAttrs: privateParameters,
                        kSecPublicKeyAttrs: publicParameters,
                        kSecAttrKeySizeInBits: Constants.keySize,
                        kSecAttrTokenID: kSecAttrTokenIDSecureEnclave] as [String: Any]
      return parameters
    } catch let error {
      throw error
    }
  }
  
  func accessControl(withProtection protcetion: CFString, flags: SecAccessControlCreateFlags = []) throws -> SecAccessControl {
    var cfError: Unmanaged<CFError>?
    let result = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protcetion, flags, &cfError)
    if let error = cfError as? Error {
      throw(error)
    }
    
    guard let accessControl = result else {
      throw(KeyError.accessControlCreation)
    }
    return accessControl
  }
}

private extension ECP256SignerTemplate {
  struct Constants {
    static let keySize = 256
    static let accessControlProtection = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
  }
}
