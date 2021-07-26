//
//  FactorFacade.swift
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

protocol FactorFacadeProtocol {
  func createFactor(withPayload payload: FactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func verifyFactor(withPayload payload: VerifyFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func updateFactor(withPayload payload: UpdateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func get(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func getAll(success: @escaping FactorListSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func delete(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func clearLocalStorage() throws
}

class FactorFacade {
  
  private let factory: PushFactoryProtocol
  private let repository: FactorProvider
  
  init(factory: PushFactoryProtocol, repository: FactorProvider) {
    self.factory = factory
    self.repository = repository
  }
}

extension FactorFacade: FactorFacadeProtocol {
  func createFactor(withPayload payload: FactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard let payload = payload as? PushFactorPayload else {
      let error = InputError.invalidInput(field: "invalid payload")
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(TwilioVerifyError.inputError(error: error as NSError))
      return
    }
    factory.createFactor(withAccessToken: payload.accessToken,
                         friendlyName: payload.friendlyName,
                         pushToken: payload.pushToken,
                         serviceSid: payload.serviceSid,
                         identity: payload.identity,
                         success: success,
                         failure: failure)
  }
  
  func verifyFactor(withPayload payload: VerifyFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard let payload = payload as? VerifyPushFactorPayload else {
      let error = InputError.invalidInput(field: "invalid payload")
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(TwilioVerifyError.inputError(error: error as NSError))
      return
    }
    factory.verifyFactor(withSid: payload.sid, success: success, failure: failure)
  }
  
  func updateFactor(withPayload payload: UpdateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard let payload = payload as? UpdatePushFactorPayload else {
      let error = InputError.invalidInput(field: "invalid payload")
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(TwilioVerifyError.inputError(error: error as NSError))
      return
    }
    factory.updateFactor(withSid: payload.sid, withPushToken: payload.pushToken, success: success, failure: failure)
  }
  
  func get(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      success(try repository.get(withSid: sid))
    } catch {
      failure(TwilioVerifyError.storageError(error: StorageError.error("Factor not found") as NSError))
    }
  }
  
  func getAll(success: @escaping FactorListSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      let factors = try repository.getAll()
      success(factors)
    } catch {
      failure(TwilioVerifyError.storageError(error: error as NSError))
    }
  }
  
  func delete(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factory.deleteFactor(withSid: sid, success: success, failure: failure)
  }
  
  func clearLocalStorage() throws {
    do {
      try factory.deleteAllFactors()
    } catch {
      try repository.clearLocalStorage()
    }
  }
}

extension FactorFacade {
  class Builder {
    
    private var networkProvider: NetworkProvider!
    private var keyStorage: KeyStorage!
    private var url: String!
    private var authentication: Authentication!
    private var clearStorageOnReinstall = true
    
    func setNetworkProvider(_ networkProvider: NetworkProvider) -> Self {
      self.networkProvider = networkProvider
      return self
    }
    
    func setKeyStorage(_ keyStorage: KeyStorage) -> Self {
      self.keyStorage = keyStorage
      return self
    }
    
    func setURL(_ url: String) -> Self {
      self.url = url
      return self
    }
    
    func setAuthentication(_ authentication: Authentication) -> Self {
      self.authentication = authentication
      return self
    }
    
    func setClearStorageOnReinstall(_ clearStorageOnReinstall: Bool) -> Self {
      self.clearStorageOnReinstall = clearStorageOnReinstall
      return self
    }
    
    func build() throws -> FactorFacadeProtocol {
      let factorAPIClient = FactorAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: url)
      let secureStorage = SecureStorage()
      let factorMigrations = FactorMigrations()
      let storage = try Storage(secureStorage: secureStorage, migrations: factorMigrations.migrations(), clearStorageOnReinstall: clearStorageOnReinstall)
      let repository = FactorRepository(apiClient: factorAPIClient, storage: storage)
      let factory = PushFactory(repository: repository, keyStorage: keyStorage)
      return FactorFacade(factory: factory, repository: repository)
    }
  }
}
