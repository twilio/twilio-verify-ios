//
//  KeychainMock.swift
//  TwilioSecurityTests
//
//  Created by Santiago Avila on 5/21/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioSecurity

class KeychainMock {
  var accessControlError: Error?
}

extension KeychainMock: KeychainProtocol {
  func accessControl(withProtection protection: CFString, flags: SecAccessControlCreateFlags) throws -> SecAccessControl {
    if let error = accessControlError {
      throw error
    }
    return SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection, flags, nil)!
  }
}
