//
//  NetworkError.swift
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

public enum NetworkError: LocalizedError {
  case invalidURL
  case invalidBody
  case invalidResponse(errorResponse: Data)
  case failureStatusCode(failureResponse: FailureResponse)
  case invalidData
}

extension NetworkError {
  public var errorDescription: String? {
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
  
  static func tryConvertDataToAPIError(
    _ data: Data
  ) -> APIError? {
    do {
      return try JSONDecoder().decode(
        APIError.self,
        from: data
      )
    } catch let error {
      Logger.shared.log(
        withLevel: .networking,
        message: "Unable to convert error data to Verify API error, details: \(error.localizedDescription)"
      )
      return nil
    }
  }
}
