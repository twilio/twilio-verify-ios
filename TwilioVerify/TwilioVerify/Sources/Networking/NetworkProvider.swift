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

typealias SuccessResponseBlock = (Response) -> ()
typealias FailureBlock = (Error) -> ()

protocol NetworkProvider {
  func execute(_ urlRequest: URLRequest, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
}

class NetworkAdapter: NetworkProvider {
  
  private let session: URLSession
  
  init(withSession session: URLSession = .shared) {
    self.session = session
  }
  
  func execute(_ urlRequest: URLRequest, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    session.dataTask(with: urlRequest) { result in
      switch result {
        case .success(let response):
          success(response)
        case .failure(let error):
          failure(error)
      }
    }.resume()
  }
}
