//
//  DateProvider.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 7/28/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol DateProvider {
  func getCurrentTime() -> Int
  func syncTime(_ date: String)
}

class DateAdapter: DateProvider {
  
  private let userDefaults: UserDefaults
  
  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }
  
  func getCurrentTime() -> Int {
    let timeDifference = userDefaults.integer(forKey: Constants.timeCorrectionKey)
    return localTime() + timeDifference
  }
  
  func syncTime(_ date: String) {
    guard let time = DateFormatter().RFC1123(date)?.timeIntervalSince1970 else {
      return
    }
    saveTime(Int(time))
  }
}

private extension DateAdapter {
  func localTime() -> Int {
    Int(Date().timeIntervalSince1970)
  }
  
  func saveTime(_ time: Int) {
    let timeCorrection = time - localTime()
    userDefaults.set(timeCorrection, forKey: Constants.timeCorrectionKey)
  }
}

extension DateAdapter {
  struct Constants {
    static let timeCorrectionKey = "timeCorrection"
  }
}
