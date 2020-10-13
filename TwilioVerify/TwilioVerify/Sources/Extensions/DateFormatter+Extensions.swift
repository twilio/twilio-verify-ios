//
//  DateFormatter+Extensions.swift
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

extension DateFormatter {
  func RFC3339(_ date: String) -> Date? {
    calendar = Calendar(identifier: .iso8601)
    locale = Locale(identifier: "en_US_POSIX")
    timeZone = TimeZone(secondsFromGMT: 0)
    dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return self.date(from: date)
  }
  
  func RFC1123(_ date: String) -> Date? {
    calendar = Calendar(identifier: .iso8601)
    locale = Locale(identifier: "en_US_POSIX")
    timeZone = TimeZone(secondsFromGMT: 0)
    dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
    return self.date(from: date)
  }
}
