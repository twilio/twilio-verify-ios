//
//  MigrationMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

class MigrationMock: Migration {
  var startVersion: Int
  var endVersion: Int
  private(set) var callsToMigrate = 0
  var migrateData: (() -> [Entry])!
  
  init(startVersion: Int, endVersion: Int) {
    self.startVersion = startVersion
    self.endVersion = endVersion
  }
  
  func migrate(data: [Data]) -> [Entry] {
    callsToMigrate += 1
    return migrateData?() ?? []
  }
}
