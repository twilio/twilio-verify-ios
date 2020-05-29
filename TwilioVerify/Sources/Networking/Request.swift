//
//  Request.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/29/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

class Request {
  
  private var httpMethod: HttpMethod
  private var url: URL
  private var body: [String: Any]
  private var headers: [String: Any]
  
  required init(withHttpMethod httpMethod: HttpMethod, url: URL, body: [String: Any], headers: [String: Any]){
    self.httpMethod = httpMethod
    self.url = url
    self.body = body
    self.headers = headers
  }
}
