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
  
  var originalError: NSError {
    switch self {
      case .networkError(let error),
           .mapperError(let error),
           .storageError(let error),
           .inputError(let error),
           .keyStorageError(let error),
           .initializationError(let error):
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
    }
  }
  //TODO: define properly error codes
  var code: Int {
    switch self {
      case .networkError:
        return 32001
      case .mapperError:
        return 32002
      case .storageError:
        return 32003
      case .inputError:
        return 32004
      case .keyStorageError:
        return 32005
      case .initializationError:
        return 32006
    }
  }
}

enum InputError: LocalizedError {
  case invalidInput
  
  var localizedDescription: String {
    switch self {
      case .invalidInput:
        return "Invalid input"
    }
  }
}
