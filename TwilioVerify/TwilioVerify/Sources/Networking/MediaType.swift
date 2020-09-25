//
//  MediaType.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

enum MediaType {
  case urlEncoded
  case json
}

extension MediaType {
  var value: String {
    switch self {
      case .urlEncoded:
        return "application/x-www-form-urlencoded"
      case .json:
        return "application/json"
    }
  }
}
