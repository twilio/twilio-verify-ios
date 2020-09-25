//
//  DateProviderMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

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
