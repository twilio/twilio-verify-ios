//
//  HTTPMethod.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

enum HTTPMethod {
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
