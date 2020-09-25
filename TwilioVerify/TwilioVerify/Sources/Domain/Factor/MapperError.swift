//
//  MapperError.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

enum MapperError: LocalizedError {
  case invalidDate
  case invalidArgument
  case illegalArgument
}

extension MapperError {
  var errorDescription: String? {
    switch self {
      case .invalidDate:
        return "Invalid date format"
      case .invalidArgument:
        return "ServiceSid or Identity is null or empty"
      case .illegalArgument:
        return "Invalid factor type from data"
    }
  }
}
