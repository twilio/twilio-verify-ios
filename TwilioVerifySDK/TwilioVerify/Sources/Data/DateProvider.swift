//
//  DateProvider.swift
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
