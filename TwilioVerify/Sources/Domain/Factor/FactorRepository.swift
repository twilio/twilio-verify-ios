//
//  FactorRepository.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/9/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol FactorProvider {
  func create(withPayload payload: CreateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping FailureBlock)
  func verify(_ factor: Factor, payload: String, success: @escaping FactorSuccessBlock, failure: @escaping FailureBlock)
  func delete(_ factor: Factor, success: @escaping EmptySuccessBlock, failure: @escaping FailureBlock)
  func getAll(success: @escaping ([Factor]) -> (), failure: @escaping FailureBlock)
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
  func create(withPayload createFactorPayload: CreateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping FailureBlock) {
    apiClient.create(withPayload: createFactorPayload, success: { [weak self] response in
      guard let strongSelf = self else { return }
      do {
        let factor = try strongSelf.factorMapper.fromAPI(withData: response.data, factorPayload: createFactorPayload)
        success(try strongSelf.save(factor))
      } catch {
        failure(error)
      }
    }, failure: failure)
  }
  
  func verify(_ factor: Factor, payload: String, success: @escaping FactorSuccessBlock, failure: @escaping FailureBlock) {
    apiClient.verify(factor, authPayload: payload, success: { [weak self] response in
      guard let strongSelf = self else { return }
      do {
        let status = try strongSelf.factorMapper.status(fromData: response.data)
        var updatedFactor = factor
        updatedFactor.status = status
        success(try strongSelf.save(updatedFactor))
      } catch {
        failure(error)
      }
    }, failure: failure)
  }
  
  func delete(_ factor: Factor, success: @escaping EmptySuccessBlock, failure: @escaping FailureBlock) {
    apiClient.delete(factor, success: { [weak self] in
      guard let strongSelf = self else { return }
      do {
        try strongSelf.storage.removeValue(for: factor.sid)
        success()
      } catch {
        failure(error)
      }
    }, failure: failure)
  }
  
  func getAll(success: @escaping ([Factor]) -> (), failure: @escaping FailureBlock) {
    do {
      let factors = try storage.getAll().compactMap {
        try? factorMapper.fromStorage(withData: $0)
      }
      success(factors)
    } catch {
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
