//
//  FactorMapper.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/5/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol FactorMapperProtocol {
  func fromAPI(withData data: Data, factorPayload: FactorDataPayload) throws -> Factor
  func fromStorage(withData data: Data) throws -> Factor
  func toData(_ factor: Factor) throws -> Data
  func status(fromData data: Data) throws -> FactorStatus
}

class FactorMapper: FactorMapperProtocol {
  
  func fromAPI(withData data: Data, factorPayload: FactorDataPayload) throws -> Factor {
    let serviceSid = factorPayload.serviceSid
    let entityIdentity = factorPayload.entity
    guard !serviceSid.isEmpty, !entityIdentity.isEmpty else {
      throw TwilioVerifyError.mapperError(error: MapperError.invalidArgument as NSError)
    }
    
    var factor: Factor
    switch factorPayload.type {
      case .push:
        factor = try toPushFactor(serviceSid: serviceSid, entityIdentity: entityIdentity, data: data)
    }
    return factor
  }
  
  func fromStorage(withData data: Data) throws -> Factor {
    guard let jsonFactor = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
      let type = jsonFactor[(\Factor.type).toString] as? String,
      let factorType = FactorType(rawValue: type) else {
        throw MapperError.invalidArgument
    }
    switch factorType {
      case .push:
        return try JSONDecoder().decode(PushFactor.self, from: data)
    }
  }
  
  func toData(_ factor: Factor) throws -> Data {
    switch factor.type {
      case .push:
        return try JSONEncoder().encode(factor as? PushFactor)
    }
  }
  
  func status(fromData data: Data) throws -> FactorStatus {
    guard let jsonFactor = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
      let status = jsonFactor[(\Factor.status).toString] as? String,
      let factorStatus = FactorStatus(rawValue: status) else {
        throw MapperError.invalidArgument
    }
    return factorStatus
  }
}

private extension FactorMapper {
  func toPushFactor(serviceSid: String, entityIdentity: String, data: Data) throws -> PushFactor {
    do {
      let pushFactorDTO = try JSONDecoder().decode(PushFactorDTO.self, from: data)
      guard let date = DateFormatter().RFC3339(pushFactorDTO.createdAt) else {
        throw MapperError.invalidDate
      }
      
      let pushFactor = PushFactor(status: pushFactorDTO.status, sid: pushFactorDTO.sid, friendlyName: pushFactorDTO.friendlyName,
                                  accountSid: pushFactorDTO.accountSid, serviceSid: serviceSid, entityIdentity: entityIdentity,
                                  createdAt: date, config: Config(credentialSid: pushFactorDTO.config.credentialSid))
      return pushFactor
    } catch {
      throw TwilioVerifyError.mapperError(error: error as NSError)
    }
  }
}
