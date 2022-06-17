//
//  OperationErrors.swift
//  TwilioVerify
//
//  Copyright © 2022 Twilio.
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

public protocol OperationError: LocalizedError {
  var errorDescription: String? { get }
  var domain: String { get }
}

enum KeychainError: OperationError {
  case unexpectedError
  case unableToCopyItem
  case unableToGeneratePublicKey
  case unableToGeneratePrivateKey
  case invalidStatusCode(code: Int)
  case errorCreatingAccessControl(cause: Error)
  case invalidProtection(code: Int)
  case createSignatureError(cause: Error)
  
  var errorDescription: String? {
    switch self {
      case .invalidStatusCode(let code):
        return String.invalidStatusCode(code)
      case .invalidProtection(let code):
        return "SecAccessControl: invalid protection: \(code)"
      case .createSignatureError(let cause):
        return "Keychain: error creating signature: \(cause.localizedDescription)"
      case .errorCreatingAccessControl(let cause):
        return cause.localizedDescription
      default:
        return String(describing: self)
    }
  }
  
  var domain: String {
    switch self {
      case .invalidProtection,
          .invalidStatusCode,
          .createSignatureError,
          .errorCreatingAccessControl:
        return NSOSStatusErrorDomain
      default:
        return "Domain not available"
    }
  }
}

public enum SecureStorageError: OperationError {
  case invalidStatusCode(code: Int)
  
  public var errorDescription: String? {
    switch self {
      case .invalidStatusCode(let code):
        return String.invalidStatusCode(code)
    }
  }
  
  public var domain: String {
    switch self {
      case .invalidStatusCode:
        return NSOSStatusErrorDomain
    }
  }
}

public enum KeyManagerError: OperationError {
  case invalidStatusCode(code: Int)
  
  public var errorDescription: String? {
    switch self {
      case .invalidStatusCode(let code):
        return String.invalidStatusCode(code)
    }
  }
  
  public var domain: String {
    switch self {
      case .invalidStatusCode:
        return NSOSStatusErrorDomain
    }
  }
}

private extension String {
  static func invalidStatusCode(_ code: Int) -> String {
    "Invalid status code operation received: \(code)"
  }
}
