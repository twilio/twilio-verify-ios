//
//  ChallengeFacade.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio.
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
    guard !sid.isEmpty else {
      let error: InputError = .emptyChallengeSid
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      return failure(.inputError(error: error))
    }
    factorFacade.get(withSid: factorSid, success: { [weak self] factor in
      guard let strongSelf = self else { return }
      switch factor {
        case is PushFactor:
          // swiftlint:disable:next force_cast
          strongSelf.pushChallengeProcessor.getChallenge(withSid: sid, withFactor: factor as! PushFactor, success: success, failure: failure)
        default:
          let error =  InputError.invalidInput(field: "invalid factor")
          Logger.shared.log(withLevel: .error, message: error.localizedDescription)
          failure(TwilioVerifyError.inputError(error: error))
      }
    }, failure: failure)
  }

  func update(withPayload updateChallengePayload: UpdateChallengePayload, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.get(withSid: updateChallengePayload.factorSid, success: { [weak self] factor in
      guard let strongSelf = self else { return }
      switch factor {
        case is PushFactor:
          // swiftlint:disable:next force_cast
          strongSelf.updatePushChallenge(updateChallengePayload: updateChallengePayload, factor: factor as! PushFactor, success: success, failure: failure)
        default:
          let error = InputError.invalidInput(field: "invalid factor")
          Logger.shared.log(withLevel: .error, message: error.localizedDescription)
          failure(TwilioVerifyError.inputError(error: error))
      }
    }, failure: failure)
  }

  func getAll(withPayload challengeListPayload: ChallengeListPayload, success: @escaping (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.get(withSid: challengeListPayload.factorSid, success: { [weak self] factor in
      guard let strongSelf = self else { return }
      strongSelf.repository.getAll(for: factor, status: challengeListPayload.status,
                                   pageSize: challengeListPayload.pageSize, order: challengeListPayload.order, pageToken: challengeListPayload.pageToken, success: success) { error in
        failure(TwilioVerifyError.networkError(error: error))
      }
    }, failure: failure)
  }
}

private extension ChallengeFacade {
  private func updatePushChallenge(updateChallengePayload: UpdateChallengePayload, factor: PushFactor, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock
  ) {
    guard let payload = updateChallengePayload as? UpdatePushChallengePayload else {
      let error: InputError = .invalidUpdateChallengePayload(
        factorType: factor.type
      )
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(TwilioVerifyError.inputError(error: error))
      return
    }
    guard !updateChallengePayload.challengeSid.isEmpty else {
      let error: InputError = .emptyChallengeSid
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      return failure(TwilioVerifyError.inputError(error: error))
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
