//
//  FactorMigrations.swift
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

struct FactorMigrations {
  func migrations() -> [Migration] {
    []
  }
}

class AddKeychainServiceToFactors: Migration {
  
  private let secureStorage: SecureStorageProvider
  private let factorMapper: FactorMapper
  
  init(secureStorage: SecureStorageProvider,
       factorMapper: FactorMapper = FactorMapper()) {
    self.secureStorage = secureStorage
    self.factorMapper = factorMapper
  }
  
  var startVersion: Int = 0
  
  var endVersion: Int = 1
  
  func migrate(data: [Data]) -> [Entry] {
    guard let factorsWithoutAccountName = try? secureStorage.getAll(withServiceName: nil) else {
      return []
    }
    let factors = data.compactMap { item in
      return try? factorMapper.fromStorage(withData: item)
    }
    return factorsWithoutAccountName.compactMap { item in
      guard let factorToUpdate = try? factorMapper.fromStorage(withData: item) else {
        return nil
      }
      return Entry(key: factorToUpdate.sid, value: item)
    }.filter { entry in
      !factors.contains { $0.sid == entry.key}
    }
  }
}
