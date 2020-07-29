//
//  DateFormatter+Extensions.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/8/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
