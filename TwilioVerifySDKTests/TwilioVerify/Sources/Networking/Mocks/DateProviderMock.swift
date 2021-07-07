//
//  DateProviderMock.swift
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
@testable import TwilioVerifySDK

class DateProviderMock {
  var currentTime: Int?
  private(set) var syncTimeCalled = false
}

extension DateProviderMock: DateProvider {
  func getCurrentTime() -> Int {
    if let currentTime = currentTime {
      return currentTime
    }
    fatalError("Expected params not set")
  }
  
  func syncTime(_ date: String) {
    syncTimeCalled = true
  }
}
