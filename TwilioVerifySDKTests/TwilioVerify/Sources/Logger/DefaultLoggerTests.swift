//
//  DefaultLoggerTests.swift
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
@testable import TwilioVerifySDK

class DefaultLoggerTests: XCTestCase {
  
  var osLog: OSLogWrapperMock!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    osLog = OSLogWrapperMock()
  }
  
  func testInit_withAllLevel_levelPropertyShouldBeAll() {
    let logger = DefaultLogger(withLevel: .all, osLog: osLog)
    XCTAssertEqual(logger.level, .all)
  }
  
  func testLog_withDifferentLevelThanSettedLevel_shouldNotLog() {
    let expectedMessage = "message"
    let callsToLog = 0
    let logger = DefaultLogger(withLevel: .error, osLog: osLog)
  
    logger.log(withLevel: .debug, message: expectedMessage, redacted: false)
    
    XCTAssertEqual(osLog.callsToLog, callsToLog)
    XCTAssertNil(osLog.message)
  }
  
  func testLog_withSameLevelAsSettedLevel_shouldLog() {
    let expectedMessage = "message"
    let callsToLog = 1
    let logger = DefaultLogger(withLevel: .error, osLog: osLog)
    
    logger.log(withLevel: .error, message: expectedMessage, redacted: false)
    
    XCTAssertEqual(osLog.callsToLog, callsToLog)
    XCTAssertNotNil(osLog.message)
    XCTAssertEqual(osLog.message, expectedMessage)
  }
}
