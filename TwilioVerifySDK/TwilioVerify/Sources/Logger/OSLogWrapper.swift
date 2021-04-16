//
//  OSLogWrapper.swift
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

protocol OSLogWrappable {
  func log(_ message: String, type: OSLogType, redacted: Bool)
}

class OSLogWrapper: OSLogWrappable {
  func log(_ message: String, type: OSLogType, redacted: Bool) {
    if #available(iOS 12.0, *) {
      os_log(type, redacted ? Constants.privateLogFormat : Constants.publicLogFormat, message)
    } else {
      os_log(redacted ? Constants.privateLogFormat : Constants.publicLogFormat, message)
    }
  }
}

private extension OSLogWrapper {
  struct Constants {
    static let publicLogFormat: StaticString = "%{public}@"
    static let privateLogFormat: StaticString = "%{private}@"
  }
}
