//
//  KeyManagerMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
@testable import TwilioVerify

class KeyManagerMock {
  var error: Error?
  var signer: Signer!
}

extension KeyManagerMock: KeyManagerProtocol {
  func signer(withTemplate template: SignerTemplate) throws -> Signer {
    if let error = error {
      throw error
    }
    return signer
  }
  
  func deleteKey(withAlias alias: String) throws {
    if let error = error {
      throw error
    }
  }
}
