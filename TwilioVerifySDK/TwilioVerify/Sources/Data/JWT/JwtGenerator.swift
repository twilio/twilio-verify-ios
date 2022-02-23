//
//  JwtGenerator.swift
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

protocol JwtGeneratorProtocol {
  func generateJWT(forHeader header: [String: String], forPayload payload: [String: Any], withSignerTemplate signerTemplate: SignerTemplate) throws -> String
}

class JwtGenerator {
  
  private let jwtSigner: JwtSignerProtocol
  
  init(withJwtSigner jwtSigner: JwtSignerProtocol) {
    self.jwtSigner = jwtSigner
  }
}

extension JwtGenerator: JwtGeneratorProtocol {
  
  func generateJWT(forHeader header: [String: String], forPayload payload: [String: Any], withSignerTemplate signerTemplate: SignerTemplate) throws -> String {
    var jwtHeader = header
    jwtHeader[Constants.typeKey] = Constants.jwtType
    if signerTemplate is ECP256SignerTemplate {
      jwtHeader[Constants.algorithmKey] = Constants.defaultAlg
    }
    let encodedHeader = try base64EncodedUrlSafeString(withData: JSONSerialization.data(withJSONObject: jwtHeader, options: []))
    let encodedPayload = try base64EncodedUrlSafeString(withData: JSONSerialization.data(withJSONObject: payload, options: []))
    let message = "\(encodedHeader).\(encodedPayload)"
    let signature = base64EncodedUrlSafeString(withData: try jwtSigner.sign(message: message, withSignerTemplate: signerTemplate))
    return "\(message).\(signature)"
  }
}

extension JwtGenerator {
  struct Constants {
    static let typeKey = "typ"
    static let jwtType = "JWT"
    static let algorithmKey = "alg"
    static let defaultAlg = "ES256"
  }
}

private extension JwtGenerator {
  func base64EncodedUrlSafeString(withData data: Data) -> String {
    data.base64EncodedString()
        .replacingOccurrences(of: "%", with: "_")
        .replacingOccurrences(of: "=", with: "")
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
  }
}
