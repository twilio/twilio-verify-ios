//
//  AuthenticatedSecureStorage.swift
//  TwilioSecurity
//
//  Copyright © 2021 Twilio.
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
import LocalAuthentication

///: nodoc:
public typealias SuccessBlock = (Data) -> ()
///: nodoc:
public typealias ErrorBlock = (Error) -> ()

///: nodoc:
public protocol AuthenticatedSecureStorageProvider {
  func save(_ data: Data, withKey key: String, authenticator: Authenticator, success: @escaping EmptySuccessBlock, failure: @escaping ErrorBlock, withServiceName service: String?)
  func get(_ key: String, authenticator: Authenticator, success: @escaping SuccessBlock, failure: @escaping ErrorBlock)
  func removeValue(for key: String) throws
  func clear(withServiceName service: String?) throws
}

///: nodoc:
public class AuthenticatedSecureStorage {

  public enum Errors: Error, LocalizedError {
    case authenticationFailed(Error?)

    public var errorDescription: String? {
      switch self {
        case .authenticationFailed: return "Authentication failed"
      }
    }
  }

  private let keychain: KeychainProtocol
  private let keychainQuery: KeychainQueryProtocol

  public convenience init(accessGroup: String?) {
    self.init(keychain: Keychain(accessGroup: accessGroup), keychainQuery: KeychainQuery(accessGroup: accessGroup))
  }

  init(keychain: KeychainProtocol,
       keychainQuery: KeychainQueryProtocol) {
    self.keychain = keychain
    self.keychainQuery = keychainQuery
  }
}

extension AuthenticatedSecureStorage: AuthenticatedSecureStorageProvider {
  public func save(_ data: Data, withKey key: String, authenticator: Authenticator, success: @escaping EmptySuccessBlock, failure: @escaping ErrorBlock, withServiceName service: String?) {
    evaluatePolicy(for: authenticator, success: {
      do {
        Logger.shared.log(withLevel: .info, message: "Saving \(key)")
        let accessControl = try self.getAccessControl()
        let query = self.keychainQuery.save(data: data, withKey: key, accessControl: accessControl, context: authenticator.context, withServiceName: service)
        let status = self.keychain.addItem(withQuery: query)
        guard status == errSecSuccess else {
          let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
          Logger.shared.log(withLevel: .error, message: error.localizedDescription)
          failure(error)
          return
        }
        Logger.shared.log(withLevel: .debug, message: "Saved \(key)")
        self.storeBiometricPolicyState(with: key, with: authenticator.context, withServiceName: service)
        success()
      } catch {
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(error)
      }
    }, failure: failure)
  }

  public func get(_ key: String, authenticator: Authenticator, success: @escaping SuccessBlock, failure: @escaping ErrorBlock) {
    canEvaluatePolicy(for: authenticator, success: {
      Logger.shared.log(withLevel: .info, message: "Getting \(key)")
      let query = self.keychainQuery.getData(withKey: key, authenticationPrompt: authenticator.localizedAuthenticationPrompt)
      do {
        let result = try self.keychain.copyItemMatching(query: query, attempts: Constants.biomettricAttempts)
        // swiftlint:disable:next force_cast
        let data = result as! Data
        Logger.shared.log(withLevel: .debug, message: "Return value for \(key)")
        success(data)
      } catch {

        Logger.shared.log(withLevel: .info, message: "Verifying biometrics policy state for key: \(key)")
        if let biometricPolicyState = self.getBiometricPolicyState(for: key),
           let evaluatedPolicyDomainState = authenticator.context.evaluatedPolicyDomainState {
          guard biometricPolicyState == evaluatedPolicyDomainState else {
            Logger.shared.log(withLevel: .error, message: "User did change biometrics")
            failure(BiometricError.didChangeBiometrics)
            return
          }
        }

        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        if let keychainError = error as? KeychainError, let biometricError = BiometricError.given(keychainError) {
          failure(biometricError)
        } else {
          failure(error)
        }
      }
    }, failure: failure)
  }

  public func removeValue(for key: String) throws {
    Logger.shared.log(withLevel: .info, message: "Removing \(key)")
    let query = keychainQuery.delete(withKey: key)
    let status = keychain.deleteItem(withQuery: query)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }

  public func clear(withServiceName service: String?) throws {
    Logger.shared.log(withLevel: .info, message: "Clearing storage")
    let query = keychainQuery.deleteItems(withServiceName: service)
    let status = keychain.deleteItem(withQuery: query)
    guard status == errSecSuccess else {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }

  private func getAccessControl() throws -> SecAccessControl {
    if #available(iOS 11.3, *) {
      return try keychain.accessControl(withProtection: Constants.accessControlProtection, flags: Constants.accessControlFlagsBiometrics)
    } else {
      return try keychain.accessControl(withProtection: Constants.accessControlProtection, flags: Constants.accessControlFlags)
    }
  }

  private func canEvaluatePolicy(for authenticator: Authenticator, success: @escaping EmptySuccessBlock, failure: @escaping ErrorBlock) {
    Logger.shared.log(withLevel: .info, message: "Validating policy")
    var error: NSError?

    guard authenticator.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error), error == nil else {
      if let biometricError = BiometricError.given(error) {
        Logger.shared.log(withLevel: .error, message: biometricError.localizedDescription)
        failure(biometricError)
      } else {
        Logger.shared.log(withLevel: .error, message: error?.localizedDescription ?? .init())
        failure(Errors.authenticationFailed(error))
      }
      return
    }

    success()
  }

  private func evaluatePolicy(for authenticator: Authenticator, success: @escaping EmptySuccessBlock, failure: @escaping ErrorBlock) {
    Logger.shared.log(withLevel: .info, message: "Evaluating policy")
    canEvaluatePolicy(for: authenticator, success: {
      authenticator.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authenticator.localizedReason) { result, error in
        if result {
          success()
        } else {
          if let error = error, let biometricError = BiometricError.given(error as NSError) {
            Logger.shared.log(withLevel: .error, message: biometricError.localizedDescription)
            failure(biometricError)
          } else {
            let error = Errors.authenticationFailed(error)
            Logger.shared.log(withLevel: .error, message: error.localizedDescription)
            failure(error)
          }
        }
      }
    }, failure: failure)
  }

  private func getBiometricPolicyState(for key: String) -> Data? {
    let policyKey = String(format: Constants.biometricsPolicyState, key)
    let query = self.keychainQuery.getData(withKey: policyKey)
    do {
      let result = try self.keychain.copyItemMatching(query: query)
      return result as? Data
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      return nil
    }
  }

  private func storeBiometricPolicyState(with key: String, with context: LAContext, withServiceName service: String?) {
    guard let evaluatePolicyState = context.evaluatedPolicyDomainState else {
      Logger.shared.log(withLevel: .error, message: "Not evaluate policy available")
      return
    }

    let policyKey = String(format: Constants.biometricsPolicyState, key)
    let query = keychainQuery.save(data: evaluatePolicyState, withKey: policyKey, withServiceName: service)
    let status = self.keychain.addItem(withQuery: query)

    if status != errSecSuccess {
      let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
    }
  }

  struct Constants {
    static let accessControlProtection = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
    @available(iOS 11.3, *)
    static let accessControlFlagsBiometrics: SecAccessControlCreateFlags = .biometryCurrentSet
    static let accessControlFlags: SecAccessControlCreateFlags = .touchIDCurrentSet
    static let biometricsPolicyState: String = "%@.biometricsPolicyState"
    static let biomettricAttempts: Int = 0
  }
}

public protocol Authenticator {
  var context: LAContext { get }
  var localizedAuthenticationPrompt: String { get }
  var localizedReason: String { get }
}
