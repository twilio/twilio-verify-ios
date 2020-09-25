//
//  TwilioVerifyError.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
  
  ///An error occurred while calling the API.
  case networkError(error: NSError)
  ///An error occurred while mapping an entity.
  case mapperError(error: NSError)
  ///An error occurred while storing/loading an entity.
  case storageError(error: NSError)
  ///An error occurred while loading input.
  case inputError(error: NSError)
  ///An error occurred while storing/loading keypairs.
  case keyStorageError(error: NSError)
  ///An error occurred while initializing a class.
  case initializationError(error: NSError)
  ///An error occurred while generating a token.
  case authenticationTokenError(error: NSError)
  
  ///Associated reason of the error
  public var originalError: NSError {
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
  
  ///Brief description of the error, indicates at which layer the error ocurred
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
   - **NetworkError:** 68001
   - **MapperError:** 68002
   - **StorageError:** 68003
   - **InputError:** 68004
   - **KeyStorageError:** 68005
   - **InitializationError:** 68006
   - **AuthenticationTokenError:** 68007
   */
  public var code: Int {
    switch self {
      case .networkError:
        return 68001
      case .mapperError:
        return 68002
      case .storageError:
        return 68003
      case .inputError:
        return 68004
      case .keyStorageError:
        return 68005
      case .initializationError:
        return 68006
      case .authenticationTokenError:
        return 68007
    }
  }
}

enum InputError: LocalizedError {
  case invalidInput
  
  var errorDescription: String? {
    switch self {
      case .invalidInput:
        return "Invalid input"
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
