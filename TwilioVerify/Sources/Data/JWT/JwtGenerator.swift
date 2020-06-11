//
//  JwtGenerator.swift
//  TwilioVerify
//
//  Created by Yeimi Moreno on 6/8/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import TwilioSecurity

protocol JwtGeneratorProtocol {
  func generateJWT(forHeader header: [String: String], forPayload payload: [String: Any], withSignerTemplate signerTemplate: SignerTemplate) throws -> String
}

class JwtGenerator: JwtGeneratorProtocol {
  
  private let jwtSigner: JwtSignerProtocol
  
  init(withJwtSigner jwtSigner: JwtSignerProtocol) {
    self.jwtSigner = jwtSigner
  }
  
  func generateJWT(forHeader header: [String: String], forPayload payload: [String: Any], withSignerTemplate signerTemplate: SignerTemplate) throws -> String {
    var jwtHeader: [String: String] = header
    jwtHeader[Constants.typeKey] = Constants.jwtType
    if signerTemplate is ECP256SignerTemplate {
      jwtHeader[Constants.algorithmKey] = Constants.defaultAlg
    }
    let encodedHeader = try base64EncodedUrlSafeString(withData: JSONSerialization.data(withJSONObject: jwtHeader, options: []))
    let encodedPayload = try base64EncodedUrlSafeString(withData: JSONSerialization.data(withJSONObject: payload, options: []))
    let message = "\(encodedHeader).\(encodedPayload)"
    let signature = base64EncodedUrlSafeString(withData: jwtSigner.sign(message: message, withSignerTemplate: signerTemplate))
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
    return data.base64EncodedString().replacingOccurrences(of: "%", with: "_").replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
  }
}
