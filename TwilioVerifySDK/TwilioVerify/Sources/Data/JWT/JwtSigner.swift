//
//  JwtSigner.swift
//  TwilioVerify
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

protocol JwtSignerProtocol {
  func sign(message: String, withSignerTemplate signerTemplate: SignerTemplate) throws -> Data
}

class JwtSigner {
  private let keyStorage: KeyStorage
  
  init(withKeyStorage keyStorage: KeyStorage) {
    self.keyStorage = keyStorage
  }
}

extension JwtSigner: JwtSignerProtocol {
  func sign(message: String, withSignerTemplate signerTemplate: SignerTemplate) throws -> Data {
    let signature = try keyStorage.sign(withAlias: signerTemplate.alias, message: message)
    switch signerTemplate {
      case is ECP256SignerTemplate:
        return try transcodeECSignatureToConcat(signature, withOutputLength: Constants.es256SignatureLength)
      default:
        return signature
    }
  }
}

private extension JwtSigner {
  struct Constants {
    static let es256SignatureLength = 64
  }
  
  func transcodeECSignatureToConcat(_ signature: Data, withOutputLength outputLength: Int) throws -> Data {
    // Parse ASN into just r,s data as defined in:
    // https://tools.ietf.org/html/rfc7518#section-3.4
    let (asnSignature, _) = toASN1Element(data: signature)
    guard case let ASN1Element.sequences(elements: seq) = asnSignature,
        seq.count >= 2,
        case let ASN1Element.bytes(data: rData) = seq[0],
        case let ASN1Element.bytes(data: sData) = seq[1]
    else {
      throw JwtSignerError.invalidFormat
    }
    // ASN adds 00 bytes in front of negative Int to mark it as positive.
    // These must be removed to make r,s a valid EC signature
    let trimmedRData: Data
    let trimmedSData: Data
    let rExtra = rData.count - outputLength/2
    if rExtra < 0 {
      trimmedRData = Data(count: 1) + rData
    } else {
      trimmedRData = rData.dropFirst(rExtra)
    }
    let sExtra = sData.count - outputLength/2
    if sExtra < 0 {
      trimmedSData = Data(count: 1) + sData
    } else {
      trimmedSData = sData.dropFirst(sExtra)
    }
    return trimmedRData + trimmedSData
  }
}

private extension JwtSigner {

  indirect enum ASN1Element {
    case sequences(elements: [ASN1Element])
    case integer(int: Int)
    case bytes(data: Data)
    case constructed(tag: Int, elem: ASN1Element)
    case unknown
  }

  func toASN1Element(data: Data) -> (ASN1Element, Int) {
    guard data.count >= 2 else {
      return (.unknown, data.count)
    }

    switch data[0] {
      case 0x30: // sequence
        let (length, lengthOfLength) = readLength(from: data.advanced(by: 1))
        var result: [ASN1Element] = []
        var subdata = data.advanced(by: 1 + lengthOfLength)
        var alreadyRead = 0

        while alreadyRead < length {
          let (e, l) = toASN1Element(data: subdata)
          result.append(e)
          subdata = subdata.count > l ? subdata.advanced(by: l) : Data()
          alreadyRead += l
        }
        return (.sequences(elements: result), 1 + lengthOfLength + length)

      case 0x02: // integer
        let (length, lengthOfLength) = readLength(from: data.advanced(by: 1))
        if length < 8 {
          var result: Int = 0
          let subdata = data.advanced(by: 1 + lengthOfLength)
          // ignore negative case
          for i in 0..<length {
            result = 256 * result + Int(subdata[i])
          }
          return (.integer(int: result), 1 + lengthOfLength + length)
        }
        // number is too large to fit in Int; return the bytes
        return (.bytes(data: data.subdata(in: (1 + lengthOfLength) ..< (1 + lengthOfLength + length))), 1 + lengthOfLength + length)

      case let s where (s & 0xe0) == 0xa0: // constructed
        let tag = Int(s & 0x1f)
        let (length, lengthOfLength) = readLength(from: data.advanced(by: 1))
        let subdata = data.advanced(by: 1 + lengthOfLength)
        let (e, _) = toASN1Element(data: subdata)
        return (.constructed(tag: tag, elem: e), 1 + lengthOfLength + length)

      default: // octet string
        let (length, lengthOfLength) = readLength(from: data.advanced(by: 1))
        return (.bytes(data: data.subdata(in: (1 + lengthOfLength) ..< (1 + lengthOfLength + length))), 1 + lengthOfLength + length)
    }
  }

  private func readLength(from data: Data) -> (Int, Int) {
    if data[0] & 0x80 == 0x00 { // short form
      return (Int(data[0]), 1)
    } else {
      let lenghOfLength = Int(data[0] & 0x7F)
      var result: Int = 0
      for i in 1..<(1 + lenghOfLength) {
        result = 256 * result + Int(data[i])
      }
      return (result, 1 + lenghOfLength)
    }
  }
}
