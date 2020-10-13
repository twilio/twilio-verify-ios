//
//  AccessTokenAPI.swift
//  TwilioVerifyDemo
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

enum NetworkError: LocalizedError {
  
  case invalidURL
  case invalidBody
  case invalidResponse
  case invalidData
  
  var errorDescription: String? {
    switch self {
      case .invalidURL:
        return "Invalid URL"
      case .invalidBody:
        return "Invalid Body"
      case .invalidResponse:
        return "Invalid response"
      case .invalidData:
        return "Invalid Data"
    }
  }
}

protocol AccessTokensAPI {
  func accessTokens(at url: String, identity: String, success: @escaping (AccessTokenResponse) -> (), failure: @escaping (Error) -> ())
}

class AccessTokensAPIClient: AccessTokensAPI {
  
  private let urlSession: URLSession
  
  init(urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }
  
  func accessTokens(at url: String, identity: String, success: @escaping (AccessTokenResponse) -> (), failure: @escaping (Error) -> ()) {
    guard let url = URL(string: url) else {
      failure(NetworkError.invalidURL)
      return
    }
    guard let parameters = try? JSONSerialization.data(withJSONObject: ["identity": identity], options: []) else {
      failure(NetworkError.invalidData)
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = parameters
    request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
    
    let task = urlSession.dataTask(with: request) { data, response, error in
      if let error = error {
        failure(error)
        return
      }
      guard response != nil else {
        failure(NetworkError.invalidResponse)
        return
      }
      guard let data = data,
            let response = try? JSONDecoder().decode(AccessTokenResponse.self, from: data) else {
        failure(NetworkError.invalidData)
        return
      }
      success(response)
    }
    task.resume()
  }
}
