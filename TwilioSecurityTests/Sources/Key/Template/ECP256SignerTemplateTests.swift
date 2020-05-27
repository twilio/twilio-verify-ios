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

  var keyManager: KeyManagerMock!
  
  override func setUpWithError() throws {
    keyManager = KeyManagerMock()
  }
  
  //TODO: @sfierro will work on this
}
