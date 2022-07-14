//
//  ECSigner.swift
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
public protocol Signer {
  func sign(_ data: Data) throws -> Data
  func verify(_ data: Data, withSignature signature: Data) -> Bool
  func getPublic() throws -> Data
}

class ECSigner {
  
  private let keyPair: KeyPair
  private let signatureAlgorithm: SecKeyAlgorithm
  private let keychain: KeychainProtocol
  
  init(
    withKeyPair keyPair: KeyPair,
    signatureAlgorithm: SecKeyAlgorithm,
    keychain: KeychainProtocol
  ) {
    self.keyPair = keyPair
    self.signatureAlgorithm = signatureAlgorithm
    self.keychain = keychain
  }
}

extension ECSigner: Signer {
  func sign(_ data: Data) throws -> Data {
    do {
      return try keychain.sign(withPrivateKey: keyPair.privateKey, algorithm: signatureAlgorithm, dataToSign: data)
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
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
      let representation = try keychain.representation(forKey: keyPair.publicKey)
      let x962HeaderECHeader = [UInt8]([
      /* sequence          */ 0x30, 0x59,
      /* |-> sequence      */ 0x30, 0x13,
      /* |---> ecPublicKey */ 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, // http://oid-info.com/get/1.2.840.10045.2.1 (ANSI X9.62 public key type)
      /* |---> prime256v1  */ 0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, // http://oid-info.com/get/1.2.840.10045.3.1.7 (ANSI X9.62 named elliptic curve)
      /* |-> bit headers   */ 0x07, 0x03, 0x42, 0x00])
      
      var result = Data()
      result.append(Data(x962HeaderECHeader))
      result.append(representation)
      return result
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }
}
