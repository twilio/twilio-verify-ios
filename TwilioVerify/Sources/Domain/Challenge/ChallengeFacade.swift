//
//  ChallengeFacade.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/30/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol ChallengeFacadeProtocol {
  func get(withSid sid: String, withFactorSid factorSid: String, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func update(withPayload updateChallengePayload: UpdateChallengePayload, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func getAll(withPayload challengeListPayload: ChallengeListPayload, success: @escaping (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock)
}

class ChallengeFacade {
  
  private let pushChallengeProcessor: PushChallengeProcessor
  private let factorFacade: FactorFacade
  private let repository: ChallengeProvider
  
  init(pushChallengeProcessor: PushChallengeProcessor, factorFacade: FactorFacade, repository: ChallengeProvider) {
    self.pushChallengeProcessor = pushChallengeProcessor
    self.factorFacade = factorFacade
    self.repository = repository
  }
}

extension ChallengeFacade: ChallengeFacadeProtocol {
  func get(withSid sid: String, withFactorSid factorSid: String, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  func update(withPayload updateChallengePayload: UpdateChallengePayload, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    
  }
  
  func getAll(withPayload challengeListPayload: ChallengeListPayload, success: @escaping (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    
  }
}

extension ChallengeFacade {
  class Builder {
    
    private var networkProvider: NetworkProvider!
    private var jwtGenerator: JwtGenerator!
    private var factorFacade: FactorFacade!
    private var url: String!
    private var authentication: Authentication!
    
    func setNetworkProvider(_ networkProvider: NetworkProvider) -> Self {
      self.networkProvider = networkProvider
      return self
    }
    
    func setJWTGenerator(_ jwtGenerator: JwtGenerator) -> Self {
      self.jwtGenerator = jwtGenerator
      return self
    }
    
    func setFactorFacade(_ factorFacade: FactorFacade) -> Self {
      self.factorFacade = factorFacade
      return self
    }
    
    func setURL(_ url: String) -> Self {
      self.url = url
      return self
    }
    
    func setAuthentication(_ authentication: Authentication) -> Self {
      self.authentication = authentication
      return self
    }
    
    func build() -> ChallengeFacadeProtocol {
      let challengeAPIClient = ChallengeAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: url)
      let repository = ChallengeRepository(apiClient: challengeAPIClient)
      let pushChallengeProcessor = PushChallengeProcessor(challengeProvider: repository, jwtGenerator: jwtGenerator)
      return ChallengeFacade(pushChallengeProcessor: pushChallengeProcessor, factorFacade: factorFacade, repository: repository)
    }
  }
}
