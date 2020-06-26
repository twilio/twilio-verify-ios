//
//  TwilioVerifyAdapter.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import TwilioVerify

class TwilioVerifyAdapter {
  
  private var twilioVerify: TwilioVerify
  
  init() {
    twilioVerify = TwilioVerifyBuilder().build()
  }
}

extension TwilioVerifyAdapter: TwilioVerify {
  func createFactor(withInput input: FactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    twilioVerify.createFactor(withInput: input, success: { factor in
      DispatchQueue.main.async {
        success(factor)
      }
    }) { error in
      DispatchQueue.main.async {
        failure(error)
      }
    }
  }
  
  func verifyFactor(withInput input: VerifyFactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    twilioVerify.verifyFactor(withInput: input, success: { factor in
      DispatchQueue.main.async {
        success(factor)
      }
    }) { error in
      DispatchQueue.main.async {
        failure(error)
      }
    }
  }
  
  func updateFactor(withInput input: UpdateFactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
  }
  
  func getAllFactors(success: @escaping ([Factor]) -> (), failure: @escaping TwilioVerifyErrorBlock) {

  }
  
  func getChallenge(challengeSid: String, factorSid: String, success: @escaping (Challenge) -> (), failure: @escaping TwilioVerifyErrorBlock) {
  }
  
  func getAllChallenges(withInput input: ChallengeListInput, success: @escaping (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  func updateChallenge(withInput input: UpdateChallengeInput, success: @escaping () -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  func deleteFactor(withSid sid: String, success: @escaping () -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
}
