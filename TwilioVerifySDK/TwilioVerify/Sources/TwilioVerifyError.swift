//
//  TwilioVerifyError.swift
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

/**
 Error types returned by the TwilioVerify SDK. It encompasess different types of errors
 that have their own associated reasons and codes.
 
 - **NetworkError:** An error occurred while calling the API.
 - **MapperError:** An error occurred while mapping an entity.
 - **StorageError:** An error occurred while storing/loading an entity.
 - **InputError:** An error occurred while loading input.
 - **KeyStorageError:** An error occurred while storing/loading keypairs.
 - **InitializationError:** An error occurred while initializing a class.
 - **AuthenticationTokenError:** An error occurred while generating a token.
 */
public enum TwilioVerifyError: LocalizedError {
  
  /// An error occurred while calling the API.
  case networkError(error: Error)
  /// An error occurred while mapping an entity.
  case mapperError(error: Error)
  /// An error occurred while storing/loading an entity.
  case storageError(error: Error)
  /// An error occurred while loading input.
  case inputError(error: Error)
  /// An error occurred while storing/loading keypairs.
  case keyStorageError(error: Error)
  /// An error occurred while initializing a class.
  case initializationError(error: Error)
  /// An error occurred while generating a token.
  case authenticationTokenError(error: Error)
  
  /// Associated reason of the error
  public var originalError: Error {
    switch self {
      case .networkError(let error),
           .mapperError(let error),
           .storageError(let error),
           .inputError(let error),
           .keyStorageError(let error),
           .initializationError(let error),
           .authenticationTokenError(let error):
        return error
    }
  }
  
  /// Brief description of the error, indicates at which layer the error ocurred
  public var errorDescription: String? {
    switch self {
      case .networkError:
        return "Error while calling the API"
      case .mapperError:
        return "Error while mapping an entity"
      case .storageError:
        return "Error while storing/loading an entity"
      case .inputError:
        return "Error while loading input"
      case .keyStorageError:
        return "Error while storing/loading key pairs"
      case .initializationError:
        return "Error while initializing"
      case .authenticationTokenError:
        return "Error while generating token"
    }
  }

  /**
   Error code of the associated error
   - **NetworkError:**
   - **MapperError:**
   - **StorageError:**
   - **InputError:**
   - **KeyStorageError:**
   - **InitializationError:**
   - **AuthenticationTokenError:**
   */
  public var code: Int {
    switch self {
      case .networkError:
        return 60401
      case .mapperError:
        return 60402
      case .storageError:
        return 60403
      case .inputError:
        return 60404
      case .keyStorageError:
        return 60405
      case .initializationError:
        return 60406
      case .authenticationTokenError:
        return 60407
    }
  }
}

/**
 Error types returned as cause for a `TwilioVerifyError` and `InputError` code on validation errors.
 - errorDescription: message associated message of the error.
 */
public enum InputError: Error, LocalizedError {
  case invalidInput(field: String)
  case invalidPayload
  case expiredChallenge
  case alreadyUpdatedChallenge
  case notUpdatedChallenge
  case invalidChallenge
  case emptyChallengeSid
  case invalidUpdateChallengePayload(factorType: FactorType)
  case emptyFactorSid
  case wrongFactor
  case invalidFactor
  case signatureFields
  
  public var errorDescription: String? {
    switch self {
      case .invalidInput(let field):
        return "Invalid input: \(field)"
      case .invalidPayload:
        return "Payload format is not valid"
      case .expiredChallenge:
        return "Expired challenge can not be updated"
      case .alreadyUpdatedChallenge:
        return "Responded challenge can not be updated"
      case .notUpdatedChallenge:
        return "Challenge was not updated"
      case .invalidChallenge:
        return "Invalid challenge for received factor"
      case .emptyChallengeSid:
        return "Empty challenge sid"
      case .invalidUpdateChallengePayload(let factorType):
        return "Invalid update challenge payload for factor \(factorType)"
      case .emptyFactorSid:
        return "Empty factor sid"
      case .wrongFactor:
        return "Wrong factor for challenge"
      case .invalidFactor:
        return "Invalid factor"
      case .signatureFields:
        return "Signature fields or response not set"
    }
  }
}

enum StorageError: LocalizedError {
  case error(String)
  
  var errorDescription: String? {
    switch self {
      case .error(let description):
        return description
    }
  }
}

enum JwtSignerError: LocalizedError {
  case invalidFormat
  
  var errorDescription: String? {
    switch self {
      case .invalidFormat:
        return "Invalid ECDSA signature format"
    }
  }
}
