//
//  AppModel.swift
//  TwilioVerifyDemo
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

/**
 There is no need to implement exacly this behavior in your project.
 This model and dictionary is intented only for keeping states between ViewControllers
 and demostrate the `Silenty approve` behavior for your challenges.
 */
struct AppModel {
  private static let key = "factorsSilentyApproved"
  private static let userDefaults = UserDefaults(suiteName: "group.twilio.TwilioVerifyDemo")
  
  static var factorsSilentyApproved: [String: Bool] {
    get {
      userDefaults?.dictionary(forKey: key) as? [String: Bool] ?? [:]
    }
    set(value) {
      userDefaults?.set(value, forKey: key)
    }
  }
}
