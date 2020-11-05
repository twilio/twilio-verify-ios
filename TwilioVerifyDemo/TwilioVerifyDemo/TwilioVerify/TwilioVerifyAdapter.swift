//
//  TwilioVerifyAdapter.swift
//  TwilioVerifyDemo
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

import Foundation
import TwilioVerify

class TwilioVerifyAdapter {
  
  private var twilioVerify: TwilioVerify
  
  init() throws {
    twilioVerify = try TwilioVerifyBuilder().build()
  }
}

extension TwilioVerifyAdapter: TwilioVerify {
  func createFactor(withPayload payload: FactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    twilioVerify.createFactor(withPayload: payload, success: { factor in
      DispatchQueue.main.async {
        success(factor)
      }
    }) { error in
      DispatchQueue.main.async {
        failure(error)
      }
    }
  }
  
  func verifyFactor(withPayload payload: VerifyFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    twilioVerify.verifyFactor(withPayload: payload, success: { factor in
      DispatchQueue.main.async {
        success(factor)
      }
    }) { error in
      DispatchQueue.main.async {
        failure(error)
      }
    }
  }
  
  func updateFactor(withPayload payload: UpdateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    twilioVerify.updateFactor(withPayload: payload, success: { factor in
      DispatchQueue.main.async {
        success(factor)
      }
    }) { error in
      DispatchQueue.main.async {
        failure(error)
      }
    }
  }
  
  func getAllFactors(success: @escaping FactorListSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    twilioVerify.getAllFactors(success: { factors in
      DispatchQueue.main.async {
        success(factors)
      }
    }) { error in
      DispatchQueue.main.async {
        failure(error)
      }
    }
  }
  
  func getChallenge(challengeSid: String, factorSid: String, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    twilioVerify.getChallenge(challengeSid: challengeSid, factorSid: factorSid, success: { challenge in
      DispatchQueue.main.async {
        success(challenge)
      }
    }) { error in
      DispatchQueue.main.async {
        failure(error)
      }
    }
  }
  
  func getAllChallenges(withPayload payload: ChallengeListPayload, success: @escaping (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    twilioVerify.getAllChallenges(withPayload: payload, success: { list in
      DispatchQueue.main.async {
        success(list)
      }
    }) { error in
      DispatchQueue.main.async {
        failure(error)
      }
    }
  }
  
  func updateChallenge(withPayload payload: UpdateChallengePayload, success: @escaping () -> (), failure: @escaping TwilioVerifyErrorBlock) {
    twilioVerify.updateChallenge(withPayload: payload, success: {
      DispatchQueue.main.async {
        success()
      }
    }) { error in
      DispatchQueue.main.async {
        failure(error)
      }
    }
  }
  
  func deleteFactor(withSid sid: String, success: @escaping () -> (), failure: @escaping TwilioVerifyErrorBlock) {
    twilioVerify.deleteFactor(withSid: sid, success: {
      DispatchQueue.main.async {
        success()
      }
    }) { error in
      DispatchQueue.main.async {
        failure(error)
      }
    }
  }
  
  func clearLocalStorage() throws {
    try twilioVerify.clearLocalStorage()
  }
}

extension TwilioVerifyError {
  var errorMessage: String {
    """
    \(localizedDescription)
    Code: \(code)
    \(originalError.localizedDescription)
    """
  }
}
