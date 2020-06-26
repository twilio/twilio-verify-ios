//
//  FactorFacade.swift
//  TwilioVerify
//
//  Created by Santiago Avila on 6/12/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import TwilioSecurity

protocol FactorFacadeProtocol {
  func createFactor(withInput input: FactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func verifyFactor(withInput input: VerifyFactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func get(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
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
  func createFactor(withInput input: FactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard let input = input as? PushFactorInput else {
      failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
      return
    }
    factory.createFactor(withJwe: input.enrollmentJwe,
                         friendlyName: input.friendlyName,
                         pushToken: input.pushToken,
                         serviceSid: input.serviceSid,
                         identity: input.identity,
                         success: success,
                         failure: failure)
  }
  
  func verifyFactor(withInput input: VerifyFactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard let input = input as? VerifyPushFactorInput else {
      failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
      return
    }
    factory.verifyFactor(withSid: input.sid, success: success, failure: failure)
  }
  
  func get(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      success(try repository.get(withSid: sid))
    } catch {
      failure(TwilioVerifyError.storageError(error: StorageError.error("Factor not found") as NSError))
    }
  }
}

extension FactorFacade {
  class Builder {
    
    private var networkProvider: NetworkProvider!
    private var keyStorage: KeyStorage!
    private var url: String!
    private var authentication: Authentication!
    
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
    
    func build() -> FactorFacadeProtocol {
      let factorAPIClient = FactorAPIClient(networkProvider: networkProvider, authentication: authentication, baseURL: url)
      let secureStorage = SecureStorage()
      let storage = Storage(secureStorage: secureStorage)
      let repository = FactorRepository(apiClient: factorAPIClient, storage: storage)
      let factory = PushFactory(repository: repository, keyStorage: keyStorage)
      return FactorFacade(factory: factory, repository: repository)
    }
  }
}
