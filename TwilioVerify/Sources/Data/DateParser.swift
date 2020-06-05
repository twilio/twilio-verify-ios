//
//  DateParser.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/5/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct DateParser {
  
  static func parse(RFC3339String date: String) -> Date? {
    formatter().date(from: date)
  }
}

private extension DateParser {
  
  static func formatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: Constants.locale)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = Constants.dateFormat
    return formatter
  }
  
  struct Constants {
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    static let locale = "en_US_POSIX"
  }
}
