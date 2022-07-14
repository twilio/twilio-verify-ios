//
//  ChallengeRepository.swift
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

protocol ChallengeProvider {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock)
  func update(_ challenge: Challenge, payload: String, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock)
  func getAll(for factor: Factor, status: ChallengeStatus?, pageSize: Int, order: ChallengeListOrder, pageToken: String?,
              success: @escaping (ChallengeList) -> (), failure: @escaping FailureBlock)
}

class ChallengeRepository {
  
  private let apiClient: ChallengeAPIClientProtocol
  private let challengeMapper: ChallengeMapperProtocol
  private let challengeListMapper: ChallengeListMapperProtocol
  
  init(apiClient: ChallengeAPIClientProtocol, challengeMapper: ChallengeMapperProtocol = ChallengeMapper(), challengeListMapper: ChallengeListMapperProtocol = ChallengeListMapper()) {
    self.apiClient = apiClient
    self.challengeMapper = challengeMapper
    self.challengeListMapper = challengeListMapper
  }
}

extension ChallengeRepository: ChallengeProvider {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock) {
    apiClient.get(withSid: sid, withFactor: factor, success: { [weak self] response in
      guard let strongSelf = self else { return }
      do {
        var challenge = try strongSelf.challengeMapper.fromAPI(withData: response.data,
                                                               signatureFieldsHeader: response.headers.first {
                                                                ($0.key as? String)?.compare(Constants.signatureFieldsHeader, options: .caseInsensitive) == .orderedSame
                                                               }?.value as? String)
        if challenge.factorSid != factor.sid {
          let error: InputError = .wrongFactor
          Logger.shared.log(withLevel: .error, message: error.localizedDescription)
          failure(error)
          return
        }
        challenge.factor = factor
        success(challenge)
      } catch {
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(error)
      }
    }, failure: failure)
  }
  
  func update(_ challenge: Challenge, payload: String, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock) {
    guard let factorChallenge = challenge as? FactorChallenge else {
      let error: InputError = .invalidChallenge
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(error)
      return
    }
    guard let factor = factorChallenge.factor else {
      let error: InputError = .invalidFactor
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(error)
      return
    }
    if factorChallenge.status == .expired {
      let error: InputError = .expiredChallenge
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      return failure(error)
    }
    guard factorChallenge.status == .pending else {
      let error: InputError = .alreadyUpdatedChallenge
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(error)
      return
    }
    apiClient.update(factorChallenge, withAuthPayload: payload, success: { [weak self] _ in
      guard let strongSelf = self else { return }
      strongSelf.get(withSid: factorChallenge.sid, withFactor: factor, success: success, failure: failure)
    }, failure: failure)
  }
  
  func getAll(for factor: Factor, status: ChallengeStatus?, pageSize: Int, order: ChallengeListOrder, pageToken: String?,
              success: @escaping (ChallengeList) -> (), failure: @escaping FailureBlock) {
    apiClient.getAll(forFactor: factor, status: status?.rawValue, pageSize: pageSize, order: order, pageToken: pageToken, success: { [weak self] response in
      guard let strongSelf = self else { return }
      do {
        let challengeList = try strongSelf.challengeListMapper.fromAPI(withData: response.data)
        success(challengeList)
      } catch {
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(error)
      }
    }, failure: failure)
  }
}

extension ChallengeRepository {
  struct Constants {
    static let signatureFieldsHeader = "Twilio-Verify-Signature-Fields"
  }
}
