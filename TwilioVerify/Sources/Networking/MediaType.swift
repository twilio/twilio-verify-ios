//
//  MediaType.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/29/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

enum MediaType{
  
  case urlEncoded
  case json
  
  var value: String {
    switch self{
      case .urlEncoded:
        return "application/x-www-form-urlencoded"
      case .json:
        return "application/json"
    }
  }
}
