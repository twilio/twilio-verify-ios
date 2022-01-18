//
//  FactorRepository.swift
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

protocol FactorProvider {
  func create(withPayload payload: CreateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping FailureBlock)
  func verify(_ factor: Factor, payload: String, success: @escaping FactorSuccessBlock, failure: @escaping FailureBlock)
  func update(withPayload payload: UpdateFactorDataPayload, success: @escaping FactorSuccessBlock, failure: @escaping FailureBlock)
  func delete(_ factor: Factor, success: @escaping EmptySuccessBlock, failure: @escaping FailureBlock)
  func delete(_ factor: Factor) throws
  func getAll() throws -> [Factor]
  func get(withSid sid: String) throws -> Factor
  func save(_ factor: Factor) throws -> Factor
  func clearLocalStorage() throws
}

class FactorRepository {
  
  private let apiClient: FactorAPIClientProtocol
  private let storage: StorageProvider
  private let factorMapper: FactorMapperProtocol
  
  init(apiClient: FactorAPIClientProtocol, storage: StorageProvider, factorMapper: FactorMapperProtocol = FactorMapper()) {
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
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
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
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(error)
      }
    }, failure: failure)
  }
  
  func update(withPayload payload: UpdateFactorDataPayload, success: @escaping FactorSuccessBlock, failure: @escaping FailureBlock) {
    do {
      let factor = try get(withSid: payload.factorSid)
      apiClient.update(factor, updateFactorDataPayload: payload, success: { [weak self] response in
        guard let strongSelf = self else { return }
        do {
          success(try strongSelf.factorMapper.fromAPI(withData: response.data, factorPayload: payload))
        } catch {
          Logger.shared.log(withLevel: .error, message: error.localizedDescription)
          failure(error)
        }
      }, failure: failure)
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(error)
    }
  }
  
  func delete(_ factor: Factor, success: @escaping EmptySuccessBlock, failure: @escaping FailureBlock) {
    apiClient.delete(factor, success: { [weak self] in
      guard let strongSelf = self else { return }
      do {
        try strongSelf.delete(factor)
        success()
      } catch {
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(error)
      }
    }, failure: failure)
  }
  
  func delete(_ factor: Factor) throws {
    try storage.removeValue(for: factor.sid)
  }
  
  func getAll() throws -> [Factor] {
    let factors = try storage.getAll().compactMap {
      try? factorMapper.fromStorage(withData: $0)
    }
    return factors
  }
  
  func save(_ factor: Factor) throws -> Factor {
    try storage.save(factorMapper.toData(factor), withKey: factor.sid)
    return try get(withSid: factor.sid)
  }
  
  func get(withSid sid: String) throws -> Factor {
    let factorData = try storage.get(sid)
    return try factorMapper.fromStorage(withData: factorData)
  }
  
  func clearLocalStorage() throws {
    do {
      try getAll().forEach { factor in
        try delete(factor)
      }
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      try storage.clear()
    }
  }
}
