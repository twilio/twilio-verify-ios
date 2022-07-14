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
  func createFactor(withAccessToken accessToken: String,
                    friendlyName: String,
                    serviceSid: String,
                    identity: String,
                    pushToken: String?,
                    metadata: [String: String]?,
                    success: @escaping FactorSuccessBlock,
                    failure: @escaping TwilioVerifyErrorBlock)
  
  func verifyFactor(withSid sid: String,
                    success: @escaping FactorSuccessBlock,
                    failure: @escaping TwilioVerifyErrorBlock)
  
  func updateFactor(withSid sid: String,
                    withPushToken pushToken: String?,
                    success: @escaping FactorSuccessBlock,
                    failure: @escaping TwilioVerifyErrorBlock)
  
  func deleteFactor(withSid sid: String,
                    success: @escaping EmptySuccessBlock,
                    failure: @escaping TwilioVerifyErrorBlock)
  
  func deleteAllFactors() throws
}

class PushFactory {
  
  private let repository: FactorProvider
  private let keyStorage: KeyStorage
  
  init(repository: FactorProvider, keyStorage: KeyStorage) {
    self.repository = repository
    self.keyStorage = keyStorage
  }
}

extension PushFactory: PushFactoryProtocol {
  func createFactor(withAccessToken accessToken: String, friendlyName: String, serviceSid: String,
                    identity: String, pushToken: String?, metadata: [String: String]?,
                    success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      Logger.shared.log(withLevel: .info, message: "Creating push factor \(friendlyName)")
      let alias = generateKeyPairAlias()
      let publicKey = try keyStorage.createKey(withAlias: alias)
      let binding = self.binding(publicKey)
      let config = self.config(withToken: pushToken)
      let payload = CreateFactorPayload(friendlyName: friendlyName, type: .push,
                                        serviceSid: serviceSid, identity: identity,
                                        config: config, binding: binding,
                                        accessToken: accessToken, metadata: metadata)
        
      Logger.shared.log(withLevel: .debug, message: "Create push factor for \(payload)")
      
      repository.create(withPayload: payload, success: { [weak self] factor in
        guard let strongSelf = self else { return }
        guard var factor = factor as? PushFactor else {
          failure(TwilioVerifyError.networkError(error: NetworkError.invalidData))
          return
        }
        factor.keyPairAlias = alias
        do {
          let pushFactor = try strongSelf.repository.save(factor)
          success(pushFactor)
        } catch {
          do {
            Logger.shared.log(withLevel: .debug, message: "Delete key pair \(alias)")
            try strongSelf.keyStorage.deleteKey(withAlias: alias)
            failure(TwilioVerifyError.keyStorageError(error: error))
          } catch {
            Logger.shared.log(withLevel: .error, message: error.localizedDescription)
            failure(TwilioVerifyError.keyStorageError(error: error))
          }
        }
      }) { [weak self] error in
        guard let strongSelf = self else { return }
        do {
          try strongSelf.keyStorage.deleteKey(withAlias: alias)
          failure(TwilioVerifyError.networkError(error: error))
        } catch {
          Logger.shared.log(withLevel: .error, message: error.localizedDescription)
          failure(TwilioVerifyError.keyStorageError(error: error))
        }
      }
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(TwilioVerifyError.keyStorageError(error: error))
    }
  }
  
  func verifyFactor(withSid sid: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      Logger.shared.log(withLevel: .info, message: "Verifying push factor \(sid)")
      let factor = try repository.get(withSid: sid)
      guard let pushFactor = factor as? PushFactor else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Factor not found") ))
        return
      }
      guard let alias = pushFactor.keyPairAlias else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Alias not found") ))
        return
      }
      let payload = try keyStorage.signAndEncode(withAlias: alias, message: sid)
      Logger.shared.log(withLevel: .debug, message: "Verify factor with payload \(payload)")
      repository.verify(pushFactor, payload: payload, success: success) { error in
        failure(TwilioVerifyError.networkError(error: error))
      }
    } catch {
      if let error = error as? TwilioVerifyError {
        failure(error)
      } else {
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(TwilioVerifyError.storageError(error: error))
      }
    }
  }
  
  func updateFactor(withSid sid: String,
                    withPushToken pushToken: String?,
                    success: @escaping FactorSuccessBlock,
                    failure: @escaping TwilioVerifyErrorBlock) {
    do {
      Logger.shared.log(withLevel: .info, message: "Updating push factor \(sid)")
      let factor = try repository.get(withSid: sid)
      guard let pushFactor = factor as? PushFactor else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Factor not found") ))
        return
      }
      let payload = UpdateFactorDataPayload(
        friendlyName: pushFactor.friendlyName,
        type: pushFactor.type,
        serviceSid: pushFactor.serviceSid,
        identity: pushFactor.identity,
        config: config(withToken: pushToken),
        factorSid: pushFactor.sid)
      Logger.shared.log(withLevel: .debug, message: "Update push factor with payload \(payload)")
      repository.update(withPayload: payload, success: success) { error in
        failure(TwilioVerifyError.networkError(error: error))
      }
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(TwilioVerifyError.storageError(error: error))
    }
  }
  
  func deleteFactor(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    do {
      Logger.shared.log(withLevel: .info, message: "Deleting push factor \(sid)")
      let factor = try repository.get(withSid: sid)
      guard let pushFactor = factor as? PushFactor else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Factor not found") ))
        return
      }
      guard let alias = pushFactor.keyPairAlias else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Alias not found") ))
        return
      }
      repository.delete(factor, success: { [weak self] in
        guard let strongSelf = self else { return }
        do {
          try strongSelf.keyStorage.deleteKey(withAlias: alias)
          success()
        } catch {
          Logger.shared.log(withLevel: .error, message: error.localizedDescription)
          failure(TwilioVerifyError.keyStorageError(error: error))
        }
      }, failure: { error in
        failure(TwilioVerifyError.networkError(error: error))
      })
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      failure(TwilioVerifyError.storageError(error: error))
    }
  }
  
  func deleteAllFactors() throws {
    Logger.shared.log(withLevel: .info, message: "Deleting factors")
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
    static let nonePushType = "none"
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
  
  func config(withToken token: String?) -> [String: String] {
    var configuration = [
      Constants.sdkVersionKey: Constants.sdkVersion,
      Constants.appIdKey: Bundle.main.bundleIdentifier ?? .init()
    ]
    
    if let token = token, !token.isEmpty {
      configuration[Constants.notificationTokenKey] = token
      configuration[Constants.notificationPlatformKey] = Constants.pushType
    } else {
      configuration[Constants.notificationPlatformKey] = Constants.nonePushType
    }
    
    return configuration
  }
}
