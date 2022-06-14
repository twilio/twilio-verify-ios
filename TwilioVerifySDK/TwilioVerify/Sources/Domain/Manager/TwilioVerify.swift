//
//  TwilioVerify.swift
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

///:nodoc:
public typealias FactorSuccessBlock = (Factor) -> ()
///:nodoc:
public typealias TwilioVerifyErrorBlock = (TwilioVerifyError) -> ()
///:nodoc:
public typealias ChallengeSuccessBlock = (Challenge) -> ()
///:nodoc:
public typealias FactorListSuccessBlock = ([Factor]) -> ()
///:nodoc:
public typealias EmptySuccessBlock = () -> ()

///Describes the available operations to proccess Factors and Challenges
public protocol TwilioVerify {
  
  /**
   Creates a **Factor** from a **FactorPayload**
   - Parameters:
     - payload: Describes the information needed to create a factor
     - success: Closure to be called when the operation succeeds, returns the created Factor
     - failure: Closure to be called when the operation fails with the cause of failure
   */
  func createFactor(
    withPayload payload: FactorPayload,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )
  
  /**
  Verifies a **Factor** from a **VerifyFactorPayload**
  - Parameters:
    - payload: Describes the information needed to verify a factor
    - success: Closure to be called when the operation succeeds, returns the verified Factor
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  func verifyFactor(
    withPayload payload: VerifyFactorPayload,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  /**
  Updates a **Factor** from a **UpdateFactorPayload**
  - Parameters:
    - payload: Describes the information needed to update a factor
    - success: Closure to be called when the operation succeeds, returns the updated Factor
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  func updateFactor(
    withPayload payload: UpdateFactorPayload,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  /**
  Gets all **Factors** created by the app, this method will return the factors in local storage.
  - Parameters:
    - success: Closure to be called when the operation succeeds, returns an array of Factors
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  func getAllFactors(
    success: @escaping FactorListSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  /**
  Deletes a **Factor** with the given **sid**. This method calls **Verify Push API** to delete
  the factor and will remove the factor from local storage if the API call succeeds.
  - Parameters:
    - sid: Sid of the **Factor** to be deleted
    - success: Closure to be called when the operation succeeds
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  func deleteFactor(
    withSid sid: String,
    success: @escaping EmptySuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )
  
  /**
  Gets a **Challenge** with the given Challenge sid and Factor sid
  - Parameters:
    - challengeSid: Sid of the Challenge requested
    - factorSid: Sid of the Factor to which the Challenge corresponds
    - success: Closure to be called when the operation succeeds, returns the requested Challenge
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  func getChallenge(
    challengeSid: String,
    factorSid: String,
    success: @escaping ChallengeSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  /**
  Updates a **Challenge** from a **UpdateChallengePayload**
  - Parameters:
     - payload: Describes the information needed to update a challenge
     - success: Closure to be called when the operation succeeds
     - failure: Closure to be called when the operation fails with the cause of failure
  */
  func updateChallenge(
    withPayload payload: UpdateChallengePayload,
    success: @escaping EmptySuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )
  
  /**
  Gets all Challenges associated to a **Factor** with the given **ChallengeListPayload**
  - Parameters:
     - payload: Describes the information needed to fetch all the **Challenges**
     - success: Closure to be called when the operation succeeds, returns a ChallengeList
                which contains the Challenges and the metadata associated to the request
     - failure: Closure to be called when the operation fails with the cause of failure
  */
  func getAllChallenges(
    withPayload payload: ChallengeListPayload,
    success: @escaping (ChallengeList) -> (),
    failure: @escaping TwilioVerifyErrorBlock
  )
  
  /**
   Clears local storage, it will delete factors and key pairs in this device.
   - throws: An error, if there is an error clearing the local storage.
   ## Important Note ##
   Calling this method will not delete factors in **Verify Push API**, so you need to delete
   them from your backend to prevent invalid/deleted factors when getting factors for an identity.
   */
  func clearLocalStorage() throws
}

/// Builder class that builds an instance of TwilioVerifyManager, which handles all the operations
/// regarding Factors and Challenges
public class TwilioVerifyBuilder {
  private var networkProvider: NetworkProvider
  private var _baseURL: String
  private var clearStorageOnReinstall: Bool
  private var accessGroup: String?
  private var loggingServices: [LoggerService]
  
  /// Creates a new instance of TwilioVerifyBuilder
  public init() {
    networkProvider = NetworkAdapter()
    _baseURL = baseURL
    clearStorageOnReinstall = true
    loggingServices = []
  }

  /// Set the NetworkProvider that will be used by the `TwilioVerify` instance.
  /// - Parameter networkProvider: instance of a `NetworkProvider`
  public func setNetworkProvider(_ networkProvider: NetworkProvider) -> Self {
    self.networkProvider = networkProvider
    return self
  }
  
  /// Defines if the storage will be cleared after a reinstall
  /// - Parameter clearStorageOnReinstall: If true, the storage will be cleared after a reinstall, so created factors will not exist in the device anymore.
  /// If false, created factors will persist in the device. Default value is true
  public func setClearStorageOnReinstall(_ clearStorageOnReinstall: Bool) -> Self {
    self.clearStorageOnReinstall = clearStorageOnReinstall
    return self
  }

  /// Set the accessGroup that will be used for the Keychain storage.
  /// - Parameter accessGroup: Used to specify the access group for the [kSecAttrAccessGroup](https://developer.apple.com/documentation/security/ksecattraccessgroup?language=swift)
  /// of the KeyChain.
  /// if `nil` the data will be only available in the app, otherwise using a KeyChain group will enable the option to access data from service extensions.
  public func setAccessGroup(_ accessGroup: String?) -> Self {
    self.accessGroup = accessGroup
    return self
  }

  /**
   Enables the default logger
    - Parameters:
      - level: Desired level of logging
   */
  public func enableDefaultLoggingService(withLevel level: LogLevel) -> Self {
    loggingServices.append(DefaultLogger(withLevel: level))
    return self
  }
  
  /**
   Adds a custom Logging Service
    - Parameters:
      - service: Custom logging service to be used to log information
   */
  public func addLoggingService(_ service: LoggerService) -> Self {
    loggingServices.append(service)
    return self
  }

  /// Set the UserDefaults group that will be used to store configurations
  private func userDefaults() -> UserDefaults {
    if let accessGroup = accessGroup, let userDefaults = UserDefaults(suiteName: accessGroup) {
      return userDefaults
    } else {
      return UserDefaults.standard
    }
  }

  /**
   Buids an instance of TwilioVerifyManager
   - Throws: `TwilioVerifyError.initializationError` if an error occurred while initializing.
   - Returns: An instance of `TwilioVerify`.
   */
  public func build() throws -> TwilioVerify {
    do {
      loggingServices.forEach { Logger.shared.addService($0) }
      let keychainQuery = KeychainQuery(accessGroup: accessGroup)
      let keyChain = Keychain(accessGroup: accessGroup)
      let keyStorage = KeyStorageAdapter(keyManager: KeyManager(withKeychain: keyChain, keychainQuery: keychainQuery))
      let jwtGenerator = JwtGenerator(withJwtSigner: JwtSigner(withKeyStorage: keyStorage))
      let authentication = AuthenticationProvider(withJwtGenerator: jwtGenerator, dateProvider: DateAdapter(userDefaults: userDefaults()))
      let factorFacade = try FactorFacade.Builder()
        .setNetworkProvider(networkProvider)
        .setURL(_baseURL)
        .setAuthentication(authentication)
        .setKeychain(keyChain)
        .setKeyStorage(keyStorage)
        .setClearStorageOnReinstall(clearStorageOnReinstall)
        .setAccessGroup(accessGroup)
        .setUserDefaults(userDefaults())
        .build()
      let challengeFacade = ChallengeFacade.Builder()
        .setNetworkProvider(networkProvider)
        .setJWTGenerator(jwtGenerator)
        .setURL(_baseURL)
        .setAuthentication(authentication)
        .setFactorFacade(factorFacade)
        .build()
      return TwilioVerifyManager(factorFacade: factorFacade, challengeFacade: challengeFacade)
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw TwilioVerifyError.initializationError(error: error)
    }
  }
}
