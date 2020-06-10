//
//  FactorRepository.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/9/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol FactorProvider {
  func create(createFactorPayload: CreateFactorPayload, success: @escaping (Factor) -> (), failure: @escaping (Error) -> ())
  
  func get(sid: String) throws -> Factor
  
  func save(factor: Factor) throws -> Factor
}

class FactorRepository: FactorProvider {
  
  private let apiClient: FactorAPIClient
  private let storage: StorageProvider
  private let factorMapper: FactorMapper
  
  init(apiClient: FactorAPIClient, storage: StorageProvider, factorMapper: FactorMapper = FactorMapper()){
    self.apiClient = apiClient
    self.storage = storage
    self.factorMapper = factorMapper
  }

  func create(createFactorPayload: CreateFactorPayload, success: @escaping (Factor) -> (), failure: @escaping (Error) -> ()) {
    apiClient.create(createFactorPayload: createFactorPayload, success: { response in
      do {
        let factor = try self.factorMapper.fromAPI(withData: response.data, factorPayload: createFactorPayload)
        success(try self.save(factor: factor))
      } catch {
        failure(error)
      }
    }) { error in
      failure(error)
    }
  }
  
  func save(factor: Factor) throws -> Factor {
    try storage.save(factorMapper.toData(forFactor: factor), withKey: factor.sid)
    return try get(sid: factor.sid)
  }
  
  func get(sid: String) throws -> Factor {
    let factorData = try storage.get(sid)
    return try factorMapper.fromStorage(withData: factorData)
  }
}
