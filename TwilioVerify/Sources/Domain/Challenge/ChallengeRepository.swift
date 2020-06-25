//
//  ChallengeRepository.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public typealias ChallengeSuccessBlock = (Challenge) -> ()

protocol ChallengeProvider {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock)
  func update(_ challenge: Challenge, payload: String, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock)
  func getAll(withFactor factor: Factor, status: ChallengeStatus?, pageSize: Int, pageToken: String?, success: @escaping (ChallengeList) -> (), failure: @escaping FailureBlock)
}

class ChallengeRepository {
  
}

extension ChallengeRepository: ChallengeProvider {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock) {
    
  }
  
  func update(_ challenge: Challenge, payload: String, success: @escaping ChallengeSuccessBlock, failure: @escaping FailureBlock) {
    
  }
  
  func getAll(withFactor factor: Factor, status: ChallengeStatus?, pageSize: Int, pageToken: String?, success: @escaping (ChallengeList) -> (), failure: @escaping FailureBlock) {
    
  }
}
