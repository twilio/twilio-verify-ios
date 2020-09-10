//
//  TwilioVerify.swift
//  TwilioVerify
//
//  Created by Santiago Avila on 6/18/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
  Gets all **Factors** created by the app
  - Parameters:
    - success: Closure to be called when the operation succeeds, returns an array of Factors
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  func getAllFactors(
    success: @escaping FactorListSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  /**
  Deletes a **Factor** with the given **Sid**
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
}

/// Builder class that builds an instance of TwilioVerifyManager, which handles all the operations
/// regarding Factors and Challenges
public class TwilioVerifyBuilder {
  
  private var keyStorage: KeyStorage
  private var networkProvider: NetworkProvider
  private var baseURL: String!
  private var jwtGenerator: JwtGenerator
  private var authentication: Authentication
  private var clearStorageOnReinstall = true
  
  ///Creates a new instance of TwilioVerifyBuilder
  public init() {
    keyStorage = KeyStorageAdapter()
    networkProvider = NetworkAdapter()
    jwtGenerator = JwtGenerator(withJwtSigner: JwtSigner())
    authentication = AuthenticationProvider(withJwtGenerator: jwtGenerator)
    guard let baseURL = Bundle(for: TwilioVerifyBuilder.self).object(forInfoDictionaryKey: Constants.baseURLKey) as? String else {
        return
    }
    self.baseURL = Constants.httpsPrefix + baseURL
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
    self.baseURL = url
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
        .setURL(baseURL)
        .setAuthentication(authentication)
        .setClearStorageOnReinstall(clearStorageOnReinstall)
        .build()
      let challengeFacade = ChallengeFacade.Builder()
        .setNetworkProvider(networkProvider)
        .setJWTGenerator(jwtGenerator)
        .setURL(baseURL)
        .setAuthentication(authentication)
        .setFactorFacade(factorFacade)
        .build()
      return TwilioVerifyManager(factorFacade: factorFacade, challengeFacade: challengeFacade)
    } catch {
      throw TwilioVerifyError.initializationError(error: error as NSError)
    }
  }
}

private extension TwilioVerifyBuilder {
  struct Constants {
    static let baseURLKey = "BaseURL"
    static let httpsPrefix = "https://"
  }
}
