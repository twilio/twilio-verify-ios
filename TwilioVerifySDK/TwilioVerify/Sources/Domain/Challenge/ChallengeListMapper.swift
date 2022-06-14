//
//  ChallengeListMapper.swift
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

protocol ChallengeListMapperProtocol {
  func fromAPI(withData data: Data) throws -> ChallengeList
}

class ChallengeListMapper {
  
  private let challengeMapper: ChallengeMapperProtocol
  
  init(challengeMapper: ChallengeMapperProtocol = ChallengeMapper()) {
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
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw TwilioVerifyError.mapperError(error: error)
    }
  }
}

extension ChallengeListMapper {
  struct Constants {
    static let pageToken = "PageToken"
  }
}
