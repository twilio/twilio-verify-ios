//
//  URLSession+Extensions.swift
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

extension URLSession {
  func dataTask(with request: URLRequest, result: @escaping (Result<Response, Error>) -> Void) -> URLSessionDataTask {
    return dataTask(with: request) { data, response, error in
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
      Logger.shared.log(withLevel: .networking, message: "Response code: \(response.statusCode)")
      guard response.statusCode < 300 else {
        let failureResponse = FailureResponse(responseCode: response.statusCode, errorData: data, headers: response.allHeaderFields)
        Logger.shared.log(withLevel: .networking, message: "Error body: \(String(data: data, encoding: .utf8))")
        result(.failure(NetworkError.failureStatusCode(failureResponse: failureResponse)))
        return
      }
      Logger.shared.log(withLevel: .networking, message: "Response headers: \(response.allHeaderFields.map {"\($0): \($1)"}.joined(separator: ", "))")
      Logger.shared.log(withLevel: .networking, message: "Response body: \(String(data: data, encoding: .utf8))")
      result(.success(Response(data: data, headers: response.allHeaderFields)))
    }
  }
}
