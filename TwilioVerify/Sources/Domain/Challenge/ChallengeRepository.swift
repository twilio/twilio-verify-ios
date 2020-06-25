//
//  ChallengeRepository.swift
//  TwilioVerify
//
//  Created by Yeimi Moreno on 6/24/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol ChallengeProvider {
  func get(forSid sid: String, withFactor factor: Factor, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
}
