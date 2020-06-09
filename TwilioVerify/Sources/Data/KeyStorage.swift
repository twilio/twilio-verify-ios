//
//  KeyStorage.swift
//  TwilioVerify
//
//  Created by Santiago Avila on 6/9/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import TwilioSecurity

protocol KeyStorage {
  func createKey(withAlias alias: String) throws -> String
  func sign(withAlias alias: String, message: String) throws -> Data
  func signAndEncode(withAlias alias: String, message: String) throws -> String
}

class KeyStorageAdapter {
  
  private let keyManager: KeyManagerProtocol
  
  init(keyManager: KeyManagerProtocol = KeyManagerBuilder().build()) {
    self.keyManager = keyManager
  }
}

extension KeyStorageAdapter: KeyStorage {
  func createKey(withAlias alias: String) throws -> String {
    do {
      let template = try signerTemplate(withAlias: alias)
      let signer = try keyManager.signer(withTemplate: template)
      let publicKey = try signer.getPublic()
      return publicKey.base64EncodedString()
    } catch {
      throw error
    }
  }
  
  func sign(withAlias alias: String, message: String) throws -> Data {
    do {
      let template = try signerTemplate(withAlias: alias)
      let signer = try keyManager.signer(withTemplate: template)
      let signature = try signer.sign(message.data(using: .utf8)!)
      return signature
    } catch {
      throw error
    }
  }
  
  func signAndEncode(withAlias alias: String, message: String) throws -> String {
    do {
      let signature = try sign(withAlias: alias, message: message)
      return signature.base64EncodedString()
    } catch {
      throw error
    }
  }
}

private extension KeyStorageAdapter {
  func signerTemplate(withAlias alias: String, shouldExist: Bool = true) throws -> SignerTemplate {
    return try ECP256SignerTemplate(withAlias: alias, shouldExist: shouldExist)
  }
}
