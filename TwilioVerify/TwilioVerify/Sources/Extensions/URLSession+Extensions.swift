//
//  URLSession+Extensions.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

extension URLSession {
  func dataTask(with request: URLRequest, result: @escaping (Result<Response, Error>) -> Void) -> URLSessionDataTask {
    return dataTask(with: request) { (data, response, error) in
      if let error = error {
        result(.failure(error))
        return
      }
      guard let data = data else {
        result(.failure(NetworkError.invalidData))
        return
      }
      guard let response = response as? HTTPURLResponse else {
        result(.failure(NetworkError.invalidResponse(errorResponse: data)))
        return
      }
      guard response.statusCode < 300 else {
        let failureResponse = FailureResponse(responseCode: response.statusCode, errorData: data, headers: response.allHeaderFields)
        result(.failure(NetworkError.failureStatusCode(failureResponse: failureResponse)))
        return
      }
      result(.success(Response(data: data, headers: response.allHeaderFields)))
    }
  }
}

internal struct FailureResponse {
  let responseCode: Int
  let errorData: Data
  let headers: [AnyHashable: Any]
}
