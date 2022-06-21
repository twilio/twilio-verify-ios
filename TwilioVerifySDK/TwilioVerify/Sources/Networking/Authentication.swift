//
//  Authentication.swift
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
  
  init(
    withJwtGenerator jwtGenerator: JwtGeneratorProtocol,
    dateProvider: DateProvider
  ) {
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
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw TwilioVerifyError.authenticationTokenError(error: error)
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
