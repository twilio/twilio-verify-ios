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
  func createFactor(withPayload payload: FactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func verifyFactor(withPayload payload: VerifyFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func updateFactor(withPayload payload: UpdateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func get(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func getAll(success: @escaping FactorListSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func delete(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
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
      failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
      return
    }
    factory.createFactor(withJwe: payload.enrollmentJwe,
                         friendlyName: payload.friendlyName,
                         pushToken: payload.pushToken,
                         serviceSid: payload.serviceSid,
                         identity: payload.identity,
                         success: success,
                         failure: failure)
  }
  
  func verifyFactor(withPayload payload: VerifyFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard let payload = payload as? VerifyPushFactorPayload else {
      failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
      return
    }
    factory.verifyFactor(withSid: payload.sid, success: success, failure: failure)
  }
  
  func updateFactor(withPayload payload: UpdateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    guard let payload = payload as? UpdatePushFactorPayload else {
      failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
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
    repository.getAll(success: success) { error in
      failure(TwilioVerifyError.storageError(error: error as NSError))
    }
  }
  
  func delete(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factory.deleteFactor(withSid: sid, success: success, failure: failure)
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
