//
//  MigrationMock.swift
//  TwilioVerifyTests
//
//  Created by Yeimi Moreno on 9/10/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
