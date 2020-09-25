//
//  UserDefaultsMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
