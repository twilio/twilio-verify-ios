//
//  ECP256SignerTemplateTests.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioSecurity

class ECP256SignerTemplateTests: XCTestCase {

  var keychainManager: KeyManagerMock!
  
  override func setUpWithError() throws {
    keychainManager = KeyManagerMock()
  }
  
  //TODO: @sfierro will work on this
}
