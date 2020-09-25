//
//  SignerMock.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
