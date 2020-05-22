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
  
  var code: Int {
    switch self {
    case .networkError:
      return 1
    case .mapperError:
      return 2
    case .storageError:
      return 3
    case .inputError:
      return 4
    case .keyStorageError:
      return 5
    case .initializationError:
      return 6
    }
  }
}
