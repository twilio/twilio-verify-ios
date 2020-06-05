//
//  FactorMapper.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/5/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

class FactorMapper {
  
  func fromAPI(withData data: Data, factorPayload: FactorPayload) throws -> Factor {
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
}

private extension FactorMapper {
  func toPushFactor(serviceSid: String, entityIdentity: String, data: Data) throws -> PushFactor {
    do {
      let pushFactorDTO = try JSONDecoder().decode(PushFactorDTO.self, from: data)
      guard let date = DateParser.parse(RFC3339String: pushFactorDTO.createdAt) else {
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
