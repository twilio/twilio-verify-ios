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
  private let challengeFacade: ChallengeFacadeProtocol
  
  init(factorFacade: FactorFacadeProtocol, challengeFacade: ChallengeFacadeProtocol) {
    self.factorFacade = factorFacade
    self.challengeFacade = challengeFacade
  }
}

extension TwilioVerifyManager: TwilioVerify {
  public func createFactor(withPayload payload: FactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.createFactor(withPayload: payload, success: success, failure: failure)
  }
  
  public func verifyFactor(withPayload payload: VerifyFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.verifyFactor(withPayload: payload, success: success, failure: failure)
  }
  
  public func updateFactor(withPayload payload: UpdateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  public func getAllFactors(success: ([Factor]) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  public func deleteFactor(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.delete(withSid: sid, success: success, failure: failure)
  }
  
  public func getChallenge(challengeSid: String, factorSid: String, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    challengeFacade.get(withSid: challengeSid, withFactorSid: factorSid, success: success, failure: failure)
  }
  
  public func updateChallenge(withPayload payload: UpdateChallengePayload, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    challengeFacade.update(withPayload: payload, success: success, failure: failure)
  }
  
  public func getAllChallenges(withPayload payload: ChallengeListPayload, success: (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
}
