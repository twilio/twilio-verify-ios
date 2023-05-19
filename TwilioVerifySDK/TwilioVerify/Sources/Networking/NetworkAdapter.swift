//
//  NetworkProvider.swift
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

final class NetworkAdapter: NetworkProvider {
  // MARK: - Properties
  private let session: URLSession
  
  // MARK: - Life Cycle
  init(withSession session: URLSession = .shared) {
    self.session = session
  }
  
  // MARK: - Internal Methods
  func execute(
    _ urlRequest: URLRequest,
    success: @escaping SuccessResponseBlock,
    failure: @escaping FailureBlock
  ) {
    log(urlRequest)
    
    session.dataTask(with: urlRequest) { result in
      switch result {
        case .success(let response):
          success(response)
          
        case .failure(let error):
          Logger.shared.log(
            withLevel: .error,
            message: error.localizedDescription
          )
          failure(error)
      }
    }.resume()
  }
  
  // MARK: - Private Methods
  private func log(_ urlRequest: URLRequest) {
    Logger.shared.log(
      withLevel: .info,
      message: "Executing \(urlRequest.httpMethod) to \(urlRequest.url)"
    )
    
    Logger.shared.log(
      withLevel: .networking,
      message: "--> \(urlRequest.httpMethod) \(urlRequest.url)"
    )
    
    urlRequest.allHTTPHeaderFields?.forEach { header in
      Logger.shared.log(
        withLevel: .networking,
        message: "\(header.key): \(header.value)"
      )
    }
    
    if let httpBody = urlRequest.httpBody, let body = String(data: httpBody, encoding: .utf8) {
      Logger.shared.log(
        withLevel: .networking,
        message: "Request: \(body)"
      )
    }
  }
}
 
// MARK: - Custom DataTask extension
private extension URLSession {
  func dataTask(
    with request: URLRequest,
    result: @escaping (Result<NetworkResponse, Error>) -> Void
  ) -> URLSessionDataTask {
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
      
      Logger.shared.log(
        withLevel: .networking,
        message: "Response code: \(response.statusCode)"
      )
      
      guard response.statusCode < 300 else {
        let failureResponse = FailureResponse(
          statusCode: response.statusCode,
          errorData: data,
          headers: response.allHeaderFields
        )
        Logger.shared.log(
          withLevel: .networking,
          message: "Error body: \(String(data: data, encoding: .utf8))"
        )
        result(.failure(NetworkError.failureStatusCode(failureResponse: failureResponse)))
        return
      }
      URLSession.log(response, data: data)
      result(.success(NetworkResponse(data: data, headers: response.allHeaderFields)))
    }
  }
  
  private static func log(_ response: HTTPURLResponse, data: Data) {
    Logger.shared.log(
      withLevel: .networking,
      message: "Response headers: \(response.allHeaderFields.map {"\($0): \($1)"}.joined(separator: ", "))"
    )
    Logger.shared.log(
      withLevel: .networking,
      message: "Response body: \(String(data: data, encoding: .utf8))"
    )
  }
}
