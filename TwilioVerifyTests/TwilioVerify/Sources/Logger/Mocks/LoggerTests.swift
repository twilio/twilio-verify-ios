//
//  LoggerTests.swift
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

class LoggerTests: XCTestCase {

  var mockService: LoggerServiceMock!
  var logger: LoggerProtocol!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    mockService = LoggerServiceMock()
    logger = Logger.shared
  }
  
  override func tearDownWithError() throws {
    logger.setLogLevel(.off)
    try super.tearDownWithError()
  }
  
  func testInit_logLevelShouldBeOff() {
    XCTAssertEqual(logger.level, .off,
                   "Log level should be \(LogLevel.off), but was \(logger.level)")
  }
  
  func testSetLogLevel_logLevelShouldMatchTheSettedOne() {
    let expectedLevel = LogLevel.networking
    logger.setLogLevel(expectedLevel)
    XCTAssertEqual(Logger.shared.level, expectedLevel,
                   "Log level should be \(expectedLevel), but was \(logger.level)")
  }

  func testAddService_servicesShouldNotBeEmpty() {
    logger.addService(mockService)
    XCTAssertFalse(logger.services.isEmpty, "Services should not be empty")
  }
  
  func testLog_withoutSettingLevel_shouldNotLog() {
    let expectedMessage = "message"
    let callsToLog = 0
    Logger.shared.addService(mockService)
    
    Logger.shared.log(withLevel: .debug, message: expectedMessage)
    
    XCTAssertEqual(mockService.callsToLog, callsToLog)
    XCTAssertNil(mockService.message)
  }
  
  func testLog_withDifferentLevelThanSettedLevel_shouldNotLog() {
    let expectedMessage = "message"
    let callsToLog = 0
    Logger.shared.addService(mockService)
    Logger.shared.setLogLevel(.networking)
    
    Logger.shared.log(withLevel: .debug, message: expectedMessage)
    
    XCTAssertEqual(mockService.callsToLog, callsToLog)
    XCTAssertNil(mockService.message)
  }
  
  func testLog_withSameLevelAsSettedLevel_shouldLog() {
    let expectedMessage = "message"
    let callsToLog = 1
    Logger.shared.addService(mockService)
    Logger.shared.setLogLevel(.networking)
    
    Logger.shared.log(withLevel: .networking, message: expectedMessage)
    
    XCTAssertEqual(mockService.callsToLog, callsToLog)
    XCTAssertNotNil(mockService.message)
    XCTAssertEqual(mockService.message, expectedMessage)
  }
}
