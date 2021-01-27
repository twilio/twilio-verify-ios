//
//  PushFactory.swift
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

protocol PushFactoryProtocol {
  func createFactor(withAccessToken accessToken: String, friendlyName: String, pushToken: String, serviceSid: String,
                    identity: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func verifyFactor(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func updateFactor(withSid sid: String, withPushToken pushToken: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func deleteFactor(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func deleteAllFactors() throws
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
  func createFactor(withAccessToken accessToken: String, friendlyName: String, pushToken: String, serviceSid: String,
                    identity: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      let alias = generateKeyPairAlias()
      let publicKey = try keyStorage.createKey(withAlias: alias)
      let binding = self.binding(publicKey)
      let config = self.config(withToken: pushToken)
      let payload = CreateFactorPayload(
        friendlyName: friendlyName,
        type: .push,
        serviceSid: serviceSid,
        identity: identity,
        config: config,
        binding: binding,
        accessToken: accessToken
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
  
  func verifyFactor(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      let factor = try repository.get(withSid: sid)
      guard let pushFactor = factor as? PushFactor else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Factor not found") as NSError))
        return
      }
      guard let alias = pushFactor.keyPairAlias else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Alias not found") as NSError))
        return
      }
      let payload = try keyStorage.signAndEncode(withAlias: alias, message: sid)
      repository.verify(pushFactor, payload: payload, success: success) { error in
        failure(TwilioVerifyError.networkError(error: error as NSError))
      }
    } catch {
      if let error = error as? TwilioVerifyError {
        failure(error)
      } else {
        failure(TwilioVerifyError.storageError(error: error as NSError))
      }
    }
  }
  
  func updateFactor(withSid sid: String, withPushToken pushToken: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      let factor = try repository.get(withSid: sid)
      guard let pushFactor = factor as? PushFactor else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Factor not found") as NSError))
        return
      }
      let payload = UpdateFactorDataPayload(
        friendlyName: pushFactor.friendlyName,
        type: pushFactor.type,
        serviceSid: pushFactor.serviceSid,
        identity: pushFactor.identity,
        config: config(withToken: pushToken),
        factorSid: pushFactor.sid)
      repository.update(withPayload: payload, success: success) { error in
        failure(TwilioVerifyError.networkError(error: error as NSError))
      }
    } catch {
      failure(TwilioVerifyError.storageError(error: error as NSError))
    }
  }
  
  func deleteFactor(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      let factor = try repository.get(withSid: sid)
      guard let pushFactor = factor as? PushFactor else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Factor not found") as NSError))
        return
      }
      guard let alias = pushFactor.keyPairAlias else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Alias not found") as NSError))
        return
      }
      repository.delete(factor, success: { [weak self] in
        guard let strongSelf = self else { return }
        do {
          try strongSelf.keyStorage.deleteKey(withAlias: alias)
          success()
        } catch {
          failure(TwilioVerifyError.keyStorageError(error: error as NSError))
        }
      }, failure: { error in
        failure(TwilioVerifyError.networkError(error: error as NSError))
      })
    } catch {
      failure(TwilioVerifyError.storageError(error: error as NSError))
    }
  }
  
  func deleteAllFactors() throws {
   let factors = try repository.getAll()
    try factors.forEach {
      try repository.delete($0)
      if let factor = $0 as? PushFactor, let keyPairAlias = factor.keyPairAlias {
        try keyStorage.deleteKey(withAlias: keyPairAlias)
      }
    }
  }
}

private extension PushFactory {
  struct Constants {
    static let publicKey = "PublicKey"
    static let pushType = "apn"
    static let sdkVersionKey = "SdkVersion"
    static let appIdKey = "AppId"
    static let sdkVersion = version
    static let notificationPlatformKey = "NotificationPlatform"
    static let notificationTokenKey = "NotificationToken"
    static let algKey = "Alg"
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
    [Constants.sdkVersionKey: Constants.sdkVersion,
     Constants.appIdKey: Bundle.main.bundleIdentifier ?? "",
     Constants.notificationPlatformKey: Constants.pushType,
     Constants.notificationTokenKey: token]
  }
}
