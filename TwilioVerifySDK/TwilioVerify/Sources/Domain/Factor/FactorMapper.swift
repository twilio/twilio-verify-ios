//
//  FactorMapper.swift
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

protocol FactorMapperProtocol {
  func fromAPI(withData data: Data, factorPayload: FactorDataPayload) throws -> Factor
  func fromStorage(withData data: Data) throws -> Factor
  func toData(_ factor: Factor) throws -> Data
  func status(fromData data: Data) throws -> FactorStatus
}

class FactorMapper: FactorMapperProtocol {
  
  func fromAPI(withData data: Data, factorPayload: FactorDataPayload) throws -> Factor {
    let serviceSid = factorPayload.serviceSid
    let identity = factorPayload.identity
    guard !serviceSid.isEmpty, !identity.isEmpty else {
      throw TwilioVerifyError.mapperError(error: MapperError.invalidArgument )
    }
    
    var factor: Factor
    switch factorPayload.type {
      case .push:
        factor = try toPushFactor(serviceSid: serviceSid, identity: identity, data: data)
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
  func toPushFactor(serviceSid: String, identity: String, data: Data) throws -> PushFactor {
    do {
      let pushFactorDTO = try JSONDecoder().decode(PushFactorDTO.self, from: data)
      guard let date = DateFormatter().RFC3339(pushFactorDTO.createdAt) else {
        throw MapperError.invalidDate
      }
      let notificationPlatform = NotificationPlatform(rawValue: pushFactorDTO.config.notificationPlatform ?? NotificationPlatform.apn.rawValue) ?? .apn
      let config = Config(credentialSid: pushFactorDTO.config.credentialSid,
                          notificationPlatform: notificationPlatform)
      
      let pushFactor = PushFactor(status: pushFactorDTO.status, sid: pushFactorDTO.sid, friendlyName: pushFactorDTO.friendlyName,
                                  accountSid: pushFactorDTO.accountSid, serviceSid: serviceSid, identity: identity,
                                  createdAt: date, config: config, metadata: pushFactorDTO.metadata)
      return pushFactor
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw TwilioVerifyError.mapperError(error: error)
    }
  }
}
