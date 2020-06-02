//
//  NetworkProvider.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

typealias SuccessBlock = (Response) -> ()
typealias FailureBlock = (Error) -> ()

class Response {
  let data: Data
  let headers: [AnyHashable: Any]
  
  init(withData data: Data, headers: [AnyHashable: Any]) {
    self.data = data
    self.headers = headers
  }
}

protocol NetworkProvider {
  func execute(_ urlRequest: URLRequest, success: @escaping SuccessBlock, failure: @escaping FailureBlock)
}
