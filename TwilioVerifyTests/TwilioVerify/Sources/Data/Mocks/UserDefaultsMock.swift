//
//  UserDefaultsMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
