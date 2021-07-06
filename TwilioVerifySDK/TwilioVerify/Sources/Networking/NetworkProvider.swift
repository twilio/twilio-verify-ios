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

public typealias SuccessResponseBlock = (Response) -> ()
public typealias FailureBlock = (Error) -> ()

public protocol NetworkProvider {
  func execute(_ urlRequest: URLRequest, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
}

class NetworkAdapter: NetworkProvider {
  
  private let session: URLSession
  
  init(withSession session: URLSession = .shared) {
    self.session = session
  }
  
  func execute(_ urlRequest: URLRequest, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    Logger.shared.log(withLevel: .info, message: "Executing \(urlRequest.httpMethod) to \(urlRequest.url)")
    Logger.shared.log(withLevel: .networking, message: "--> \(urlRequest.httpMethod) \(urlRequest.url)")
    urlRequest.allHTTPHeaderFields?.forEach { header in
      Logger.shared.log(withLevel: .networking, message: "\(header.key): \(header.value)")
    }
    if let httpBody = urlRequest.httpBody, let body = String(data: httpBody, encoding: .utf8) {
      Logger.shared.log(withLevel: .networking, message: "Request: \(body)")
    }
    session.dataTask(with: urlRequest) { result in
      switch result {
        case .success(let response):
          success(response)
        case .failure(let error):
          Logger.shared.log(withLevel: .error, message: error.localizedDescription)
          failure(error)
      }
    }.resume()
  }
}
