//
//  Response.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

class Response {
  let data: Data
  let headers: [AnyHashable: Any]
  
  init(withData data: Data, headers: [AnyHashable: Any]) {
    self.data = data
    self.headers = headers
  }
}
