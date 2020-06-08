//
//  DateFormatter+Extensions.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/8/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

extension DateFormatter {
  func RFC3339() {
    self.calendar = Calendar(identifier: .iso8601)
    self.locale = Locale(identifier: "en_US_POSIX")
    self.timeZone = TimeZone(secondsFromGMT: 0)
    self.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
  }
}
