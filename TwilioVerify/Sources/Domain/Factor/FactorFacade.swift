//
//  FactorFacade.swift
//  TwilioVerify
//
//  Created by Santiago Avila on 6/12/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol FactorFacadeProtocol {
  func createFactor(withInput input: FactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func verifyFactor(withInput input: VerifyFactorInput, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
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
}
