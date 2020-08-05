//
//  ChallengeMapper.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/24/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
        response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
      }
      
      factorChallenge.response = response
      factorChallenge.signatureFields = signatureFields
      return factorChallenge
    } catch {
      throw TwilioVerifyError.mapperError(error: error as NSError)
    }
  }
  
  func fromAPI(withChallengeDTO challengeDTO: ChallengeDTO) throws -> FactorChallenge {
    guard let expirationDate = DateFormatter().RFC3339(challengeDTO.expirationDate),
      let createdAt = DateFormatter().RFC3339(challengeDTO.createdAt),
      let updatedAt = DateFormatter().RFC3339(challengeDTO.updateAt) else {
        throw MapperError.invalidDate
    }
      
    let detailsDTO = try JSONDecoder().decode(ChallengeDetailsDTO.self, from: challengeDTO.details.data(using: .utf8)!)
    let details = ChallengeDetails(message: detailsDTO.message, fields: detailsDTO.fields ?? [], date: DateFormatter().RFC3339(detailsDTO.date ?? String()))
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