//
//  PushFactory.swift
//  TwilioVerify
//
//  Created by Santiago Avila on 6/11/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol PushFactoryProtocol {
  func createFactor(withJwe jwe: String, friendlyName: String, pushToken: String, serviceSid: String,
                    identity: String, success: @escaping (Factor) -> (), failure: @escaping FailureBlock)
}

class PushFactory {
  
  private let repository: FactorProvider
  private let keyStorage: KeyStorage
  
  init(repository: FactorProvider, keyStorage: KeyStorage = KeyStorageAdapter()) {
    self.repository = repository
    self.keyStorage = keyStorage
  }
}

extension PushFactory: PushFactoryProtocol {
  func createFactor(withJwe jwe: String, friendlyName: String, pushToken: String, serviceSid: String,
                    identity: String, success: @escaping (Factor) -> (), failure: @escaping FailureBlock) {
    do {
      let alias = generateKeyPairAlias()
      let publicKey = try keyStorage.createKey(withAlias: alias)
      let binding = self.binding(publicKey)
      let config = self.config(withToken: pushToken)
      let payload = CreateFactorPayload(
        friendlyName: friendlyName,
        type: .push,
        serviceSid: serviceSid,
        entity: identity,
        config: config,
        binding: binding,
        jwe: jwe
      )
      
      repository.create(withPayload: payload, success: { [weak self] factor in
        guard let strongSelf = self else { return }
        guard var factor = factor as? PushFactor else {
          failure(TwilioVerifyError.networkError(error: NetworkError.invalidData as NSError))
          return
        }
        factor.keyPairAlias = alias
        do {
          let pushFactor = try strongSelf.repository.save(factor)
          success(pushFactor)
        } catch {
          do {
            try strongSelf.keyStorage.deleteKey(withAlias: alias)
            failure(TwilioVerifyError.keyStorageError(error: error as NSError))
          } catch {
            failure(TwilioVerifyError.keyStorageError(error: error as NSError))
          }
        }
      }) { [weak self] error in
        guard let strongSelf = self else { return }
        do {
          try strongSelf.keyStorage.deleteKey(withAlias: alias)
          failure(TwilioVerifyError.networkError(error: error as NSError))
        } catch {
          failure(TwilioVerifyError.keyStorageError(error: error as NSError))
        }
      }
    } catch {
      failure(TwilioVerifyError.keyStorageError(error: error as NSError))
    }
  }
}

private extension PushFactory {
  struct Constants {
    static let publicKey = "public_key"
    static let pushType = "apn"
    static let sdkVersionKey = "sdk_version"
    static let appIdKey = "app_id"
    static let notificationPlatformKey = "notification_platform"
    static let notificationTokenKey = "notification_token"
    static let algKey = "alg"
    static let defaulAlg = "ES256"
    static let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  }
  
  func generateKeyPairAlias() -> String {
    let pool = Constants.alphabet.map({String($0)})
    var alias = [String](repeating: String(), count: 15)
    
    for i in 0..<alias.count {
      alias[i] = pool.randomElement()!
    }
  
    return alias.joined()
  }
  
  func binding(_ key: String) -> [String: String] {
    [Constants.publicKey: key,
     Constants.algKey: Constants.defaulAlg]
  }
  
  func config(withToken token: String) -> [String: String] {
    [Constants.sdkVersionKey: String(TwilioVerifyVersionNumber),
     Constants.appIdKey: Bundle.main.bundleIdentifier ?? "",
     Constants.notificationPlatformKey: Constants.pushType,
     Constants.notificationTokenKey: token]
  }
}
