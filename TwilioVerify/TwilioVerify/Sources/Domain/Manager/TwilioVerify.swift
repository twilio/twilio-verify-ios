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
  
  private var keyStorage: KeyStorage
  private var networkProvider: NetworkProvider
  private var _baseURL: String!
  private var jwtGenerator: JwtGenerator
  private var authentication: Authentication
  private var clearStorageOnReinstall = true
  
  ///Creates a new instance of TwilioVerifyBuilder
  public init() {
    keyStorage = KeyStorageAdapter()
    networkProvider = NetworkAdapter()
    jwtGenerator = JwtGenerator(withJwtSigner: JwtSigner())
    authentication = AuthenticationProvider(withJwtGenerator: jwtGenerator)
    self._baseURL = baseURL
  }
  
  func setNetworkProvider(_ networkProvider: NetworkProvider) -> Self {
    self.networkProvider = networkProvider
    return self
  }
  
  func setClearStorageOnReinstall(_ clearStorageOnReinstall: Bool) -> Self {
    self.clearStorageOnReinstall = clearStorageOnReinstall
    return self
  }
  
  func setURL(_ url: String) -> Self {
    self._baseURL = url
    return self
  }
  
  /**
    Buids an instance of TwilioVerifyManager
   
    - Throws: `TwilioVerifyError.initializationError` if an error occurred while initializing.
    - Returns: An instance of `TwilioVerify`.
    */
  public func build() throws -> TwilioVerify {
    do {
      let factorFacade = try FactorFacade.Builder()
        .setNetworkProvider(networkProvider)
        .setKeyStorage(keyStorage)
        .setURL(_baseURL)
        .setAuthentication(authentication)
        .setClearStorageOnReinstall(clearStorageOnReinstall)
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
      throw TwilioVerifyError.initializationError(error: error as NSError)
    }
  }
}
