//
//  Authentication.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

protocol Authentication {
  func generateJWT(forFactor factor: Factor) throws -> String
}

enum AuthenticationError: LocalizedError {
  case invalidFactor
  case invalidKeyPair
  
  var errorDescription: String? {
    switch self {
      case .invalidFactor:
        return "Not supported factor for JWT generation"
      case .invalidKeyPair:
        return "Key pair not set"
    }
  }
}

class AuthenticationProvider {
  
  private let jwtGenerator: JwtGeneratorProtocol
  private let dateProvider: DateProvider
  
  init(withJwtGenerator jwtGenerator: JwtGeneratorProtocol = JwtGenerator(),
       dateProvider: DateProvider = DateAdapter()) {
    self.jwtGenerator = jwtGenerator
    self.dateProvider = dateProvider
  }
}

extension AuthenticationProvider: Authentication {
  
  func generateJWT(forFactor factor: Factor) throws -> String {
    do {
      switch factor {
        case is PushFactor:
          // swiftlint:disable:next force_cast
          return try generateJWT(factor as! PushFactor)
        default:
          throw AuthenticationError.invalidFactor
      }
    } catch {
      throw TwilioVerifyError.authenticationTokenError(error: error as NSError)
    }
  }
}

private extension AuthenticationProvider {
  func generateJWT(_ factor: PushFactor) throws -> String {
    let header = generateHeader(factor)
    let payload = generatePayload(factor)
    guard let alias = factor.keyPairAlias else {
      throw AuthenticationError.invalidKeyPair
    }
    let signerTemplate = try ECP256SignerTemplate(withAlias: alias, shouldExist: true)
    return try jwtGenerator.generateJWT(forHeader: header, forPayload: payload, withSignerTemplate: signerTemplate)
  }
  
  func generateHeader(_ factor: PushFactor) -> [String: String] {
    [Constants.ctyKey: Constants.contentType,
     Constants.kidKey: factor.config.credentialSid]
  }
  
  func generatePayload(_ factor: PushFactor) -> [String: Any] {
    let currentDate = dateProvider.getCurrentTime()
    return [Constants.subKey: factor.accountSid,
            Constants.expKey: currentDate + Constants.jwtValidFor,
            Constants.iatKey: currentDate
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
    static let jwtValidFor = 10 * 60
    static let iatKey = "nbf"
  }
}
