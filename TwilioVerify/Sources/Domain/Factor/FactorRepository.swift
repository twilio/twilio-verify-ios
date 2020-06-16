//
//  FactorRepository.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/9/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol FactorProvider {
  func create(withPayload payload: CreateFactorPayload, success: @escaping (Factor) -> (), failure: @escaping FailureBlock)
  func get(withSid sid: String) throws -> Factor
  func save(_ factor: Factor) throws -> Factor
}

class FactorRepository {
  
  private let apiClient: FactorAPIClientProtocol
  private let storage: StorageProvider
  private let factorMapper: FactorMapperProtocol
  
  init(apiClient: FactorAPIClientProtocol, storage: StorageProvider = Storage(), factorMapper: FactorMapperProtocol = FactorMapper()){
    self.apiClient = apiClient
    self.storage = storage
    self.factorMapper = factorMapper
  }
}

extension FactorRepository: FactorProvider {
  func create(withPayload createFactorPayload: CreateFactorPayload, success: @escaping (Factor) -> (), failure: @escaping FailureBlock) {
    apiClient.create(withPayload: createFactorPayload, success: { [weak self] response in
      guard let strongSelf = self else { return }
      do {
        let factor = try strongSelf.factorMapper.fromAPI(withData: response.data, factorPayload: createFactorPayload)
        success(try strongSelf.save(factor))
      } catch {
        failure(error)
      }
    }) { error in
      failure(error)
    }
  }
  
  func save(_ factor: Factor) throws -> Factor {
    try storage.save(factorMapper.toData(factor), withKey: factor.sid)
    return try get(withSid: factor.sid)
  }
  
  func get(withSid sid: String) throws -> Factor {
    let factorData = try storage.get(sid)
    return try factorMapper.fromStorage(withData: factorData)
  }
}
