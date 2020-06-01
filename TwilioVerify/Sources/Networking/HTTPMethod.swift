//
//  HTTPMethod.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/29/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

enum HTTPMethod: Int {
  case get
  case post
  case put
  case delete
}

extension HTTPMethod {
  var value: String {
    switch self {
      case .get:
        return "GET"
      case .post:
        return "POST"
      case .put:
        return "PUT"
      case .delete:
        return "DELETE"
    }
  }
}
