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
  
  private let pushChallengeProcessor: PushChallengeProcessorProtocol
  private let factorFacade: FactorFacadeProtocol
  private let repository: ChallengeProvider
  
  init(pushChallengeProcessor: PushChallengeProcessorProtocol, factorFacade: FactorFacadeProtocol, repository: ChallengeProvider) {
    self.pushChallengeProcessor = pushChallengeProcessor
    self.factorFacade = factorFacade
    self.repository = repository
  }
}

extension ChallengeFacade: ChallengeFacadeProtocol {
  func get(withSid sid: String, withFactorSid factorSid: String, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.get(withSid: sid, success: { [weak self] factor in
      guard let strongSelf = self else { return }
      switch factor {
        case is PushFactor:
          strongSelf.pushChallengeProcessor.getChallenge(withSid: sid, withFactor: factor as! PushFactor, success: success, failure: failure)
        default:
          failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
      }
    }, failure: failure)
  }
  
  func update(withPayload updateChallengePayload: UpdateChallengePayload, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.get(withSid: updateChallengePayload.factorSid, success: { [weak self] factor in
      guard let strongSelf = self else { return }
      switch factor {
        case is PushFactor:
          strongSelf.updatePushChallenge(updateChallengePayload: updateChallengePayload, factor: factor as! PushFactor, success: success, failure: failure)
        default:
          failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
      }
    }, failure: failure)
  }
  
  func getAll(withPayload challengeListPayload: ChallengeListPayload, success: @escaping (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.get(withSid: challengeListPayload.factorSid, success: { [weak self] factor in
      guard let strongSelf = self else { return }
      strongSelf.repository.getAll(for: factor, status: challengeListPayload.status, pageSize: challengeListPayload.pageSize, pageToken: challengeListPayload.pageToken, success: success) { error in
        failure(TwilioVerifyError.networkError(error: error as NSError))
      }
    }, failure: failure)
  }
}

private extension ChallengeFacade {
  private func updatePushChallenge(updateChallengePayload: UpdateChallengePayload, factor: PushFactor, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard let payload = updateChallengePayload as? UpdatePushChallengePayload else {
      failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
      return
    }
    pushChallengeProcessor.updateChallenge(withSid: payload.challengeSid, withFactor: factor, status: payload.status, success: success, failure: failure)
  }
}

extension ChallengeFacade {
  class Builder {
    
    private var networkProvider: NetworkProvider!
    private var jwtGenerator: JwtGenerator!
    private var factorFacade: FactorFacadeProtocol!
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
    
    func setFactorFacade(_ factorFacade: FactorFacadeProtocol) -> Self {
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
