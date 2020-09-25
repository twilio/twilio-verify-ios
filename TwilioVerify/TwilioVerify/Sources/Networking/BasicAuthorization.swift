//
//  BasicAuthorization.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

class BasicAuthorization {
  
  private let username: String
  private let password: String
  
  required init(username: String, password: String) {
    self.username = username
    self.password = password
  }
  
  func header() -> HTTPHeader {
    return HTTPHeader.authorization(username: username, password: password)
  }
}
