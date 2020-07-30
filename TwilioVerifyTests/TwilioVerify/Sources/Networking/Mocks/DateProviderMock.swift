//
//  DateProviderMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 7/28/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
