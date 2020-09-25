//
//  NetworkError.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

enum NetworkError: LocalizedError {
  case invalidURL
  case invalidBody
  case invalidResponse(errorResponse: Data)
  case failureStatusCode(failureResponse: FailureResponse)
  case invalidData
}

extension NetworkError {
  var errorDescription: String? {
    switch self {
      case .invalidURL:
        return "Invalid URL"
      case .invalidBody:
        return "Invalid Body"
      case .invalidResponse:
        return "Invalid Response"
      case .invalidData:
        return "Invalid Data"
      case .failureStatusCode:
        return "Failure status scode"
    }
  }

  var errorResponse: Data? {
    switch self {
      case .invalidResponse(let errorResponse):
        return errorResponse
      default:
        return nil
    }
  }
  
  var failureResponse: FailureResponse? {
    switch self {
      case .failureStatusCode(let failureResponse):
        return failureResponse
      default:
        return nil
    }
  }
}
