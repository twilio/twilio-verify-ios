//
//  ChallengeRepository.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

protocol ChallengeProvider {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock)
  func update(_ challenge: Challenge, payload: String, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock)
  func getAll(for factor: Factor, status: ChallengeStatus?, pageSize: Int, pageToken: String?, success: @escaping (ChallengeList) -> (), failure: @escaping FailureBlock)
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
                                                               signatureFieldsHeader: response.headers[Constants.signatureFieldsHeader] as? String)
        if challenge.factorSid != factor.sid {
          failure(InputError.invalidInput)
          return
        }
        challenge.factor = factor
        success(challenge)
      } catch {
        failure(error)
      }
    }, failure: failure)
  }
  
  func update(_ challenge: Challenge, payload: String, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock) {
    guard let factorChallenge = challenge as? FactorChallenge, let factor = factorChallenge.factor, factorChallenge.status == .pending else {
      failure(InputError.invalidInput)
      return
    }
    apiClient.update(factorChallenge, withAuthPayload: payload, success: { [weak self] _ in
      guard let strongSelf = self else { return }
      strongSelf.get(withSid: factorChallenge.sid, withFactor: factor, success: success, failure: failure)
    }, failure: failure)
  }
  
  func getAll(for factor: Factor, status: ChallengeStatus?, pageSize: Int, pageToken: String?, success: @escaping (ChallengeList) -> (), failure: @escaping FailureBlock) {
    apiClient.getAll(forFactor: factor, status: status?.rawValue, pageSize: pageSize, pageToken: pageToken, success: { [weak self] response in
      guard let strongSelf = self else { return }
      do {
        let challengeList = try strongSelf.challengeListMapper.fromAPI(withData: response.data)
        success(challengeList)
      } catch {
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
