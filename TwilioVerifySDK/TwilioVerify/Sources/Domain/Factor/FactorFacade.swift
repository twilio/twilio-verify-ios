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
      let error: InputError = .invalidPayload
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(TwilioVerifyError.inputError(error: error))
      return
    }
    factory.createFactor(withAccessToken: payload.accessToken,
                         friendlyName: payload.friendlyName,
                         serviceSid: payload.serviceSid,
                         identity: payload.identity,
                         pushToken: payload.pushToken,
                         metadata: payload.metadata,
                         success: success,
                         failure: failure)
  }
  
  func verifyFactor(withPayload payload: VerifyFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard let payload = payload as? VerifyPushFactorPayload else {
      let error: InputError = .invalidPayload
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(TwilioVerifyError.inputError(error: error))
      return
    }
    guard !payload.sid.isEmpty else {
      let error: InputError = .emptyFactorSid
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      return failure(TwilioVerifyError.inputError(error: error))
    }
    factory.verifyFactor(withSid: payload.sid, success: success, failure: failure)
  }
  
  func updateFactor(withPayload payload: UpdateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard let payload = payload as? UpdatePushFactorPayload else {
      let error: InputError = .invalidPayload
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(TwilioVerifyError.inputError(error: error))
      return
    }
    guard !payload.sid.isEmpty else {
      let error: InputError = .emptyFactorSid
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      return failure(TwilioVerifyError.inputError(error: error))
    }
    factory.updateFactor(withSid: payload.sid, withPushToken: payload.pushToken, success: success, failure: failure)
  }
  
  func get(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard !sid.isEmpty else {
      let error: InputError = .emptyFactorSid
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      return failure(TwilioVerifyError.inputError(error: error))
    }
    do {
      success(try repository.get(withSid: sid))
    } catch {
      failure(TwilioVerifyError.storageError(error: StorageError.error("Factor not found") ))
    }
  }
  
  func getAll(success: @escaping FactorListSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      let factors = try repository.getAll()
      success(factors)
    } catch {
      failure(TwilioVerifyError.storageError(error: error))
    }
  }
  
  func delete(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard !sid.isEmpty else {
      let error: InputError = .emptyFactorSid
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      return failure(TwilioVerifyError.inputError(error: error))
    }
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
    private var keychain: Keychain!
    private var url: String!
    private var authentication: Authentication!
    private var clearStorageOnReinstall = true
    private var accessGroup: String?
    private var userDefaults: UserDefaults!
    
    func setNetworkProvider(_ networkProvider: NetworkProvider) -> Self {
      self.networkProvider = networkProvider
      return self
    }

    func setKeyStorage(_ keyStorage: KeyStorage) -> Self {
      self.keyStorage = keyStorage
      return self
    }

    func setKeychain(_ keychain: Keychain) -> Self {
      self.keychain = keychain
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

    public func setAccessGroup(_ accessGroup: String?) -> Self {
      self.accessGroup = accessGroup
      return self
    }

    public func setUserDefaults(_ userDefaults: UserDefaults) -> Self {
      self.userDefaults = userDefaults
      return self
    }

    func build() throws -> FactorFacadeProtocol {
      let factorAPIClient = FactorAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: url)
      let keychainQuery = KeychainQuery(accessGroup: accessGroup)
      let secureStorage = SecureStorage(keychain: keychain, keychainQuery: keychainQuery)
      let migrations = FactorMigrations().migrations()
      let storage = try Storage(secureStorage: secureStorage, keychain: keychain, userDefaults: userDefaults,
                                migrations: migrations, clearStorageOnReinstall: clearStorageOnReinstall, accessGroup: accessGroup)
      let repository = FactorRepository(apiClient: factorAPIClient, storage: storage)
      let factory = PushFactory(repository: repository, keyStorage: keyStorage)
      return FactorFacade(factory: factory, repository: repository)
    }
  }
}
