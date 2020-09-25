//
//  NetworkProvider.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
