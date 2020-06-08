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
    let formatter = DateFormatter()
    formatter.RFC3339()
    return formatter.date(from: date)
  }
}
