//
//  KeyManagerMock.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioSecurity

class KeyManagerMock {
  
  var accessControlError: Error?
  private let keychain: KeychainProtocol
  
  required init(withKeychain keychain: KeychainProtocol = KeychainMock()) {
    self.keychain = keychain
  }
}

extension KeyManagerMock: KeyManagerProtocol {

}
