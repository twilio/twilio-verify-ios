//
//  ChallengeListMapper.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol ChallengeListMapperProtocol {
  func fromAPI(withData data: Data) throws -> ChallengeList
}

class ChallengeListMapper: ChallengeListMapperProtocol {
  func fromAPI(withData data: Data) throws -> ChallengeList {
    //TODO: https://issues.corp.twilio.com/browse/ACCSEC-17936
    throw MapperError.illegalArgument
  }
}
