//
//  NetworkProvider+Models.swift
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

// MARK: - Type aliases

public typealias SuccessResponseBlock = (NetworkResponse) -> ()
public typealias FailureBlock = (Error) -> ()

// MARK: - Protocols

public protocol NetworkProvider {
  func execute(
    _ urlRequest: URLRequest,
    success: @escaping SuccessResponseBlock,
    failure: @escaping FailureBlock
  )
}

// MARK: - Models

public struct APIError: Codable {
  public let code: Int
  public let message: String
  public let moreInfo: String?
  
  public init(
    code: Int,
    message: String,
    moreInfo: String?
  ) {
    self.code = code
    self.message = message
    self.moreInfo = moreInfo
  }
  
  private enum CodingKeys: String, CodingKey {
    case code, message, moreInfo = "more_info"
  }
}

public struct FailureResponse {
  public let statusCode: Int
  public let errorData: Data
  public let headers: [AnyHashable: Any]
  public lazy var apiError: APIError? = NetworkError.tryConvertDataToAPIError(errorData)
  
  public init(
    statusCode: Int,
    errorData: Data,
    headers: [AnyHashable: Any]
  ) {
    self.statusCode = statusCode
    self.errorData = errorData
    self.headers = headers
  }
}

public struct NetworkResponse {
  public let data: Data
  public let headers: [AnyHashable: Any]
  
  public init(
    data: Data,
    headers: [AnyHashable: Any]
  ) {
    self.data = data
    self.headers = headers
  }
}
