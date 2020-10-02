//
//  Logger.swift
//  TwilioVerify
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

///Describes the available operations to log information
public protocol LoggerService {
  /**
  Logs a **Message** with the specific **Level**
  - Parameters:
    - level: Describes the level
    - message: Closure to be called when the operation succeeds, returns the created Factor
  */
  func log(withLevel level: LogLevel, message: String)
}

/**
Error types returned by the TwilioVerify SDK. It encompasess different types of errors
that have their own associated reasons and codes.

- **Off:** Turn off logging, default.
- **Error:** Log error events that might still allow the application to continue running.
- **Info:** Log the progress of the application at coarse-grained level.
- **Networking:** Log network requests.
- **Debug:** Log fine-grained informational events that are most useful to debug the application.
- **All:** Turn on all logging.
*/
public enum LogLevel {
  case off
  case error
  case info
  case networking
  case debug
  case all
}

protocol LoggerProtocol {
  var level: LogLevel {get}
  var services: [LoggerService] {get}
  func setLogLevel(_ level: LogLevel)
  func addService(_ service: LoggerService)
}

class Logger {
  
  static let shared = Logger()
  private(set) var level: LogLevel
  private(set) var services: [LoggerService]
  
  private init() {
    services = []
    level = .off
  }
}

extension Logger: LoggerProtocol {
  func setLogLevel(_ level: LogLevel) {
    self.level = level
  }
  
  func addService(_ service: LoggerService) {
    services.append(service)
  }
}

extension Logger: LoggerService {
  func log(withLevel level: LogLevel, message: String) {
    guard level == self.level, level != .off else { return }
    services.forEach {
      $0.log(withLevel: level, message: message)
    }
  }
}
