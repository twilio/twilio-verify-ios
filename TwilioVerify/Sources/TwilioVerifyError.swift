//
//  TwilioVerifyError.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/22/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

enum TwilioVerifyError: LocalizedError {
  
  case networkError(error: NSError)
  case mapperError(error: NSError)
  case storageError(error: NSError)
  case inputError(error: NSError)
  case keyStorageError(error: NSError)
  case initializationError(error: NSError)
  case authenticationTokenError(error: NSError)
  
  var originalError: NSError {
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
  
  var errorDescription: String {
    switch self {
      case .networkError:
        return "Error while calling API"
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

  var code: Int {
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
  
  var errorDescription: String {
    switch self {
      case .invalidInput:
        return "Invalid input"
    }
  }
}

enum StorageError: LocalizedError {
  case error(String)
  
  var errorDescription: String {
    switch self {
    case .error(let description):
        return description
    }
  }
}
