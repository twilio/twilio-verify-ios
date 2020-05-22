//
//  ECSigner.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

typealias KeyPair = (publicKey: SecKey, privateKey: SecKey)

protocol Signer {
  func sign(_ data: Data) throws -> Data
  func verify(_ data: Data, withSignature signature: Data) -> Bool
  func getPublic() throws -> Data
}

class ECSigner {
  
  private let keyPair: KeyPair
  private let signatureAlgorithm: SecKeyAlgorithm
  private let keychain: KeychainProtocol
  
  init(withKeyPair keyPair: KeyPair,
       signatureAlgorithm: SecKeyAlgorithm,
       keychain: KeychainProtocol = Keychain()) {
    self.keyPair = keyPair
    self.signatureAlgorithm = signatureAlgorithm
    self.keychain = keychain
  }
}

extension ECSigner: Signer {
  func sign(_ data: Data) throws -> Data {
    do {
      return try keychain.sign(withPrivateKey: keyPair.privateKey, algorithm: signatureAlgorithm, dataToSign: data)
    } catch let error {
      throw error
    }
  }
  
  func verify(_ data: Data, withSignature signature: Data) -> Bool {
    return keychain.verify(withPublicKey: keyPair.publicKey,
                           algorithm: signatureAlgorithm,
                           signedData: data,
                           signature: signature)
  }
  
  func getPublic() throws -> Data {
    do {
      return try keychain.representation(forKey: keyPair.publicKey)
    } catch let error {
      throw error
    }
  }
}
