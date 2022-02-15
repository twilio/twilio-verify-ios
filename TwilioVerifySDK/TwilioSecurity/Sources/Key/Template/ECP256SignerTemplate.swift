//
//  ECP256.swift
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

///:nodoc:
public struct ECP256SignerTemplate {
  public var alias: String
  public var shouldExist: Bool
  public var parameters: [String: Any]
  public var algorithm = kSecAttrKeyTypeECSECPrimeRandom as String
  public var signatureAlgorithm = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256
  public var accessControl: SecAccessControl
  public var accessGroup: String?
  
  public init(
    withAlias alias: String,
    shouldExist: Bool,
    accessGroup: String? = nil
  ) throws {
    try self.init(withAlias: alias, shouldExist: shouldExist, accessGroup: accessGroup, keychain: Keychain())
  }
}

extension ECP256SignerTemplate: SignerTemplate {
  init(
    withAlias alias: String,
    shouldExist: Bool,
    accessGroup: String? = nil,
    keychain: KeychainProtocol = Keychain()
  ) throws {
    self.alias = alias
    self.shouldExist = shouldExist
    self.parameters = [:]
    self.accessGroup = accessGroup
    do {
      self.accessControl = try keychain.accessControl(withProtection: Constants.accessControlProtection, flags: Constants.accessControlFlags)
      self.parameters = try createSignerParameters(keychain)
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }
}

extension ECP256SignerTemplate {
  func createSignerParameters(_ keychain: KeychainProtocol) throws -> [String: Any] {
    var privateParameters = [kSecAttrLabel: alias,
                             kSecAttrIsPermanent: true,
                             kSecAttrAccessControl: accessControl] as [CFString: Any]
    var publicParameters = [kSecAttrLabel: alias,
                            kSecAttrAccessControl: accessControl] as [CFString: Any]

    if let accessGroup = accessGroup {
      privateParameters[kSecAttrAccessGroup] = accessGroup
      publicParameters[kSecAttrAccessGroup] = accessGroup
    }

    var parameters = [kSecAttrKeyType: algorithm,
                      kSecPrivateKeyAttrs: privateParameters,
                      kSecPublicKeyAttrs: publicParameters,
                      kSecAttrKeySizeInBits: Constants.keySize] as [String: Any]
    
    if isSecureEnclaveAvailable() {
      parameters[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
    }
    return parameters
  }
  
  private func isSecureEnclaveAvailable() -> Bool {
    TARGET_OS_SIMULATOR == 0
  }
  
  struct Constants {
    static let keySize = 256
    static let accessControlProtection = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    static let accessControlFlags: SecAccessControlCreateFlags = .privateKeyUsage
  }
}
