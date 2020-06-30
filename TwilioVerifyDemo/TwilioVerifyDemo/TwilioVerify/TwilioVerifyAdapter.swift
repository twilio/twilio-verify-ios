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
  }
  
  func getAllFactors(success: @escaping ([Factor]) -> (), failure: @escaping TwilioVerifyErrorBlock) {

  }
  
  func getChallenge(challengeSid: String, factorSid: String, success: @escaping (Challenge) -> (), failure: @escaping TwilioVerifyErrorBlock) {
  }
  
  func getAllChallenges(withPayload payload: ChallengeListPayload, success: @escaping (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  func updateChallenge(withPayload payload: UpdateChallengePayload, success: @escaping () -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  func deleteFactor(withSid sid: String, success: @escaping () -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
}
