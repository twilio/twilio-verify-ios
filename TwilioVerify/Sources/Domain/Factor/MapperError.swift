//
//  MapperError.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/5/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

enum MapperError: LocalizedError {
  case invalidDate
  case invalidArgument
  case illegalArgument
}

extension MapperError {
  var errorDescription: String {
    switch self {
      case .invalidDate:
        return "Invalid date format"
      case .invalidArgument:
        return "ServiceSid or EntityIdentity is null or empty"
      case .illegalArgument:
        return "Invalid factor type from data"
    }
  }
}
