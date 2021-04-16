//
//  OSLogWrapperMock.swift
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
import os
@testable import TwilioVerifySDK

class OSLogWrapperMock {
  private(set) var callsToLog = 0
  private(set) var message: String?
  private(set) var type: OSLogType = .default
}

extension OSLogWrapperMock: OSLogWrappable {
  func log(_ message: String, type: OSLogType, redacted: Bool) {
    callsToLog += 1
    self.message = message
    self.type = type
  }
}
