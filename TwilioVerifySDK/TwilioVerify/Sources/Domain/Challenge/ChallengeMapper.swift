//
//  ChallengeMapper.swift
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

protocol ChallengeMapperProtocol {
  func fromAPI(withData data: Data, signatureFieldsHeader: String?) throws -> FactorChallenge
  func fromAPI(withChallengeDTO challengeDTO: ChallengeDTO) throws -> FactorChallenge
}

class ChallengeMapper: ChallengeMapperProtocol {
  
  func fromAPI(withData data: Data, signatureFieldsHeader: String? = nil) throws -> FactorChallenge {
    do {
      let challengeDTO = try JSONDecoder().decode(ChallengeDTO.self, from: data)
      var factorChallenge = try fromAPI(withChallengeDTO: challengeDTO)
      var signatureFields: [String]?
      if challengeDTO.status == .pending && signatureFieldsHeader != nil {
        signatureFields = signatureFieldsHeader?.components(separatedBy: Constants.signatureFieldsHeaderSeparator)
      }
      
      var response: [String: Any]?
      if challengeDTO.status == .pending && signatureFields != nil {
        response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      }
      
      factorChallenge.response = response
      factorChallenge.signatureFields = signatureFields
      return factorChallenge
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw TwilioVerifyError.mapperError(error: error)
    }
  }
  
  func fromAPI(withChallengeDTO challengeDTO: ChallengeDTO) throws -> FactorChallenge {
    guard let expirationDate = DateFormatter().RFC3339(challengeDTO.expirationDate),
      let createdAt = DateFormatter().RFC3339(challengeDTO.createdAt),
      let updatedAt = DateFormatter().RFC3339(challengeDTO.updateAt) else {
        let error = MapperError.invalidDate
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        throw error
    }
      
    let details = ChallengeDetails(message: challengeDTO.details.message, fields: challengeDTO.details.fields ?? [], date: DateFormatter().RFC3339(challengeDTO.details.date ?? String()))
    let factorChallenge = FactorChallenge(
      sid: challengeDTO.sid,
      challengeDetails: details,
      hiddenDetails: challengeDTO.hiddenDetails,
      factorSid: challengeDTO.factorSid,
      status: challengeDTO.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expirationDate: expirationDate)
    return factorChallenge
  }
}

extension ChallengeMapper {
  struct Constants {
    static let signatureFieldsHeaderSeparator = ","
  }
}
