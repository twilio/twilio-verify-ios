//
//  TwilioVerifyManager.swift
//  TwilioVerify
//
//  Created by Santiago Avila on 6/18/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public class TwilioVerifyManager {
  
  private let factorFacade: FactorFacadeProtocol
  
  init(factorFacade: FactorFacadeProtocol) {
    self.factorFacade = factorFacade
  }
}

extension TwilioVerifyManager: TwilioVerify {
  public func createFactor(withInput input: FactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  public func verifyFactor(withInput input: VerifyFactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  public func updateFactor(withInput input: UpdateFactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  public func getAllFactors(success: ([Factor]) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  public func getChallenge(challengeSid: String, factorSid: String, success: (Challenge) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  public func getAllChallenges(withInput input: ChallengeListInput, success: (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  public func updateChallenge(withInput input: UpdateChallengeInput, success: () -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  public func deleteFactor(withSid sid: String, success: @escaping () -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  
}
