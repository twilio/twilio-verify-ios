//
//  SignerMock.swift
//  TwilioVerifyTests
//
//  Created by Santiago Avila on 6/9/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
@testable import TwilioVerify

class SignerMock {
  var error: Error?
  var operationresult: Data!
  var verifyShouldSucceed = false
}

extension SignerMock: Signer {
  func sign(_ data: Data) throws -> Data {
    if let error = error {
      throw error
    }
    return operationresult
  }
  
  func verify(_ data: Data, withSignature signature: Data) -> Bool {
    return verifyShouldSucceed
  }
  
  func getPublic() throws -> Data {
    if let error = error {
      throw error
    }
    return operationresult
  }
}
