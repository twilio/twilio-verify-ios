//
//  UserDefaultsMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 7/28/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

class UserDefaultsMock: UserDefaults {
  var keyName: String?
  var intValue: Int?
  
  override func integer(forKey defaultName: String) -> Int {
    if defaultName == keyName, let intValue = intValue {
      return intValue
    }
    fatalError("Expected params not set")
  }
  
  override func set(_ value: Int, forKey defaultName: String) {
    if defaultName == keyName {
      intValue = value
      return
    }
    fatalError("Expected params not set")
  }
}
