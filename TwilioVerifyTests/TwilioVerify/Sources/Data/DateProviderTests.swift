//
//  DateProviderTests.swift
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
