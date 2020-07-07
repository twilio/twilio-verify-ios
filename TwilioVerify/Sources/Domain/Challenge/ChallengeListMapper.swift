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

class ChallengeListMapper {
  
  private let challengeMapper: ChallengeMapperProtocol
  
  init(challengeMapper: ChallengeMapperProtocol = ChallengeMapper()){
    self.challengeMapper = challengeMapper
  }
}

extension ChallengeListMapper: ChallengeListMapperProtocol {
  func fromAPI(withData data: Data) throws -> ChallengeList {
    do {
      let challengeListDTO = try JSONDecoder().decode(ChallengeListDTO.self, from: data)
      var previousPageToken: String?
      var nextPageToken: String?
      if let previousUrl = challengeListDTO.meta.previousPageURL, let url = URLComponents(string: previousUrl) {
        previousPageToken = url.queryItems?.first(where: {$0.name == Constants.pageToken})?.value
      }
      if let nextUrl = challengeListDTO.meta.nextPageURL, let url = URLComponents(string: nextUrl) {
        nextPageToken = url.queryItems?.first(where: {$0.name == Constants.pageToken})?.value
      }
      let page = challengeListDTO.meta.page
      let metadata = ChallengeListMetadata(page: page, pageSize: challengeListDTO.meta.pageSize, previousPageToken: previousPageToken, nextPageToken: nextPageToken)
      let challenges = try challengeListDTO.challenges.map { try challengeMapper.fromAPI(withChallengeDTO: $0) }
      let challengeList = FactorChallengeList(challenges: challenges, metadata: metadata)
      return challengeList
    } catch {
      throw TwilioVerifyError.mapperError(error: error as NSError)
    }
  }
}

extension ChallengeListMapper {
  struct Constants {
    static let pageToken = "PageToken"
  }
}
