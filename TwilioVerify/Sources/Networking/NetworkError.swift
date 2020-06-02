//
//  NetworkError.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/29/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

enum NetworkError: LocalizedError {
  case invalidURL
  case invalidBody
}

extension NetworkError {
  var errorDescription: String {
    switch self{
      case .invalidURL:
        return "Invalid URL"
      case .invalidBody:
        return "Invalid Body"
    }
  }
}
