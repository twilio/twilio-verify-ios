//
//  KeyManagerMock.swift
//  TwilioVerifyTests
//
//  Created by Santiago Avila on 6/9/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import TwilioSecurity

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
}
