//
//  BasicAuthorization.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/29/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public class BasicAuthorization {
  
  private let username: String
  private let password: String
  
  public required init(username: String, password: String) {
    self.username = username
    self.password = password
  }
  
  public func header() -> HTTPHeader {
    return HTTPHeader.authorization(username: username, password: password)
  }
}
