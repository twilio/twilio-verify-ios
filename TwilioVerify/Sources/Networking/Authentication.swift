//
//  Authentication.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/4/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import TwilioSecurity

protocol Authentication {
  func generateJWT(forFactor factor: Factor) throws -> String
}

class AuthenticationProvider: Authentication {
  
  private let jwtGenerator: JwtGeneratorProtocol
  
  init(withJwtGenerator jwtGenerator: JwtGeneratorProtocol) {
    self.jwtGenerator = jwtGenerator
  }
  
  func generateJWT(forFactor factor: Factor) throws -> String {
    do {
      switch factor {
      case is PushFactor:
        return try generateJWT(factor as! PushFactor)
      default:
        throw AuthenticationError.invalidFactor
      }
    } catch let error {
      throw TwilioVerifyError.authenticationTokenError(error: error as NSError)
    }
  }
  
  private func generateJWT(_ factor: PushFactor) throws -> String {
    let header = generateHeader(factor)
    let payload = generatePayload(factor)
    guard let alias = factor.keyPairAlias else {
      throw AuthenticationError.invalidKeyPair
    }
    let signerTemplate = try ECP256SignerTemplate(withAlias: alias, shouldExist: true)
    return try jwtGenerator.generateJWT(forHeader: header, forPayload: payload, withSignerTemplate: signerTemplate)
  }
  
  private func generateHeader(_ factor: PushFactor) -> [String: String] {
    return [Constants.ctyKey: Constants.contentType,
            Constants.kidKey: factor.config.credentialSid]
  }
  
  private func generatePayload(_ factor: PushFactor) -> [String: Any] {
    let currentDate = Date()
    return [Constants.subKey: factor.accountSid,
            Constants.expKey: currentDate.addingTimeInterval(Constants.jwtValidFor).timeIntervalSince1970,
            Constants.iatKey: currentDate.timeIntervalSince1970
    ]
  }
}

extension AuthenticationProvider {
  struct Constants {
    static let ctyKey = "cty"
    static let kidKey = "kid"
    static let contentType = "twilio-pba;v=1"
    static let subKey = "sub"
    static let expKey = "exp"
    static let jwtValidFor: Double = 10
    static let iatKey = "nbf"
  }
}

enum AuthenticationError: LocalizedError {
    case invalidFactor
    case invalidKeyPair
}

extension AuthenticationError {
  var errorDescription: String {
    switch self {
      case .invalidFactor:
        return "Not supported factor for JWT generation"
      case .invalidKeyPair:
        return "Key pair not set"
    }
  }
}
