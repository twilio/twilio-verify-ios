//
//  NetworkAdapter.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

class NetworkAdapter: NetworkProvider {
  
  private let session: URLSession
  
  init(withSession session: URLSession = .shared) {
    self.session = session
  }
  
  func execute(_ urlRequest: URLRequest, success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
    session.dataTask(with: urlRequest) { result in
      switch result {
        case .success((let httpURLResponse, let data)):
          let response = Response(withData: data, headers: httpURLResponse.allHeaderFields)
          success(response)
        case .failure(let error):
          failure(error)
      }
    }.resume()
  }
}
