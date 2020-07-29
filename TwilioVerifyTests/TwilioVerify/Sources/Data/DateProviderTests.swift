//
//  DateProviderTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 7/28/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class DateProviderTests: XCTestCase {
  
  var dateProvider: DateProvider!
  var userDefaults: UserDefaultsMock!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    userDefaults = UserDefaultsMock()
    dateProvider = DateAdapter(userDefaults: userDefaults)
  }
  
  func testGetCurrentTime_withTimeCorrectionNotStored_shouldReturnLocalTime() {
    userDefaults.intValue = 0
    userDefaults.keyName = DateAdapter.Constants.timeCorrectionKey
    XCTAssertEqual(dateProvider.getCurrentTime(), Int(Date().timeIntervalSince1970),
                   "Current device time should be \(Int(Date().timeIntervalSince1970)) but was \(dateProvider.getCurrentTime())")
  }
  
  func testGetCurrentTime_withTimeCorrectionStored_shouldReturnLocalTimePlusTimeCorrection() {
    let timeCorrection = 1000
    userDefaults.intValue = timeCorrection
    userDefaults.keyName = DateAdapter.Constants.timeCorrectionKey
    let expectedTime = Int(Date().timeIntervalSince1970) + timeCorrection
    XCTAssertEqual(expectedTime, dateProvider.getCurrentTime())
  }
  
  func testSyncTime_withValidDate_shouldStoreTimeCorrection() {
    userDefaults.keyName = DateAdapter.Constants.timeCorrectionKey
    let date = "Tue, 21 Jul 2020 17:07:32 GMT"
    dateProvider.syncTime(date)
    XCTAssertNotNil(userDefaults.intValue)
  }
  
  func testSyncTime_withInvalidDate_shouldNotStoreTimeCorrection() {
    userDefaults.keyName = DateAdapter.Constants.timeCorrectionKey
    let date = "invalidDate"
    dateProvider.syncTime(date)
    XCTAssertNil(userDefaults.intValue)
  }
}
