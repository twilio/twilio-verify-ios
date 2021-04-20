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
import os

///Describes the available operations to log information
public protocol LoggerService {
  /**
   Desired log level
   */
  var level: LogLevel {get}
  /**
  Logs a **Message** with the specific **Level**
  - Parameters:
    - level: Describes the level
    - message: The message to be logged
    - redacted: Indicates if the message should be redacted when there's not a debugger attached to the app
  */
  func log(withLevel level: LogLevel, message: String, redacted: Bool)
}

/**
Error types returned by the TwilioVerify SDK. It encompasess different types of errors
that have their own associated reasons and codes.

- **Error:** Log error events that might still allow the application to continue running.
- **Info:** Log the progress of the application at coarse-grained level.
- **Networking:** Log network requests.
- **Debug:** Log fine-grained informational events that are most useful to debug the application.
- **All:** Turn on all logging.
*/
public enum LogLevel {
  case error
  case info
  case networking
  case debug
  case all
  
  internal var mapToOSLogType: OSLogType {
    switch self {
      case .error:
        return .error
      case .info:
        return .info
      case .debug:
        return .debug
      default:
        return .default
    }
  }
}

protocol LoggerProtocol {
  var services: [LoggerService] {get}
  func addService(_ service: LoggerService)
  func log(withLevel level: LogLevel, message: String, redacted: Bool)
}

class Logger {
  
  static let shared = Logger()
  private(set) var services: [LoggerService]
  
  private init() {
    services = []
  }
}

extension Logger: LoggerProtocol {
  func addService(_ service: LoggerService) {
    services.append(service)
  }
  
  func log(withLevel level: LogLevel, message: String, redacted: Bool = false) {
    services.forEach {
      if level == $0.level || $0.level == .all {
        $0.log(withLevel: level, message: message, redacted: redacted)
      }
    }
  }
}
