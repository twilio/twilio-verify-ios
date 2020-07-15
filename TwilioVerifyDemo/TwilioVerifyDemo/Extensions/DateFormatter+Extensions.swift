//
//  DateFormatter+Extensions.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 7/15/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

extension Date {
  func verifyStringFormat() -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "MMM d yyy, h:mm a"
    return formatter.string(from: self)
  }
}
