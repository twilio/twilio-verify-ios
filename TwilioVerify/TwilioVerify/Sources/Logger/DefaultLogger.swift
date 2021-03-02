//
//  DefaultLogger.swift
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

class DefaultLogger {
  
  private(set) var level: LogLevel
  private let osLog: OSLogWrappable
  
  init(withLevel level: LogLevel,
       osLog: OSLogWrappable = OSLogWrapper()) {
    self.level = level
    self.osLog = osLog
  }
}

extension DefaultLogger: LoggerService {
  func log(withLevel level: LogLevel, message: String, redacted: Bool) {
    guard level == self.level || self.level == .all else { return }
    osLog.log(message, type: level.mapToOSLogType, redacted: redacted)
  }
}
