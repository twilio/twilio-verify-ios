//
//  MockContext.swift
//  TwilioVerifySDKTests
//
//  Copyright © 2021 Twilio.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import LocalAuthentication

class MockContext: LAContext {

  var evaluatePolicyResult: Bool = true
  var evaluatePolicyError: Error?
  var canEvaluatePolicyResult: Bool = true
  var canEvaluatePolicyError: Error?

  convenience init(evaluatePolicyResult: Bool = true, evaluatePolicyError: Error? = nil) {
    self.init()
    self.evaluatePolicyResult = evaluatePolicyResult
    self.evaluatePolicyError = evaluatePolicyError
  }

  override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
    error?.pointee = canEvaluatePolicyError as NSError?
    return canEvaluatePolicyResult
  }

  override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void) {
    reply(evaluatePolicyResult, evaluatePolicyError)
  }
}
