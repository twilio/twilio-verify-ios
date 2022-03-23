//
//  Migration.swift
//  TwilioVerifySDK
//
//  Copyright © 2022 Twilio.
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

struct Entry {
  let key: String
  let value: Data
}

protocol Migration {
  var startVersion: Int { get }
  var endVersion: Int { get }
  /**
   Perform a migration from startVersion to endVersion. Take into account that migrations could be performed for newer versions
   when reinstalling (when clearStorageOnReinstall is false), so validate that the data needs the migration.

   - Returns:returns an array of data that needs to be migrated, adding/removing fields, etc. Empty to skip the migration.
   */
  func migrate(data: [Data]) -> [Entry]
}
