//
//  TwilioVerify.swift
//  TwilioVerify
//
//  Created by Santiago Avila on 6/18/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public typealias FactorSuccessBlock = (Factor) -> ()
public typealias TwilioVerifyErrorBlock = (TwilioVerifyError) -> ()
public typealias ChallengeSuccessBlock = (Challenge) -> ()
public typealias EmptySuccessBlock = () -> ()

public protocol TwilioVerify {
  func createFactor(
    withInput input: FactorInput,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )
  
  func verifyFactor(
    withInput input: VerifyFactorInput,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  func updateFactor(
    withInput input: UpdateFactorInput,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  func getAllFactors(
    success: ([Factor]) -> (),
    failure: @escaping TwilioVerifyErrorBlock
  )

  func getChallenge(
    challengeSid: String,
    factorSid: String,
    success: (Challenge) -> (),
    failure: @escaping TwilioVerifyErrorBlock
  )

  func getAllChallenges(
    withInput input: ChallengeListInput,
    success: (ChallengeList) -> (),
    failure: @escaping TwilioVerifyErrorBlock
  )

  func updateChallenge(
    withInput input: UpdateChallengeInput,
    success: @escaping EmptySuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  func deleteFactor(
    withSid sid: String,
    success: @escaping EmptySuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )
}

public class TwilioVerifyBuilder {
  
  private var keyStorage: KeyStorage
  private var networkProvider: NetworkProvider
  private var baseURL: String!
  private var jwtGenerator: JwtGenerator
  private var authentication: Authentication
  
  public init() {
    keyStorage = KeyStorageAdapter()
    networkProvider = NetworkAdapter()
    jwtGenerator = JwtGenerator(withJwtSigner: JwtSigner())
    authentication = AuthenticationProvider(withJwtGenerator: jwtGenerator)
  }
  
  func setNetworkProvider(_ networkProvider: NetworkProvider) -> Self {
    self.networkProvider = networkProvider
    return self
  }
  
  public func setURL(_ url: String) -> Self {
    self.baseURL = url
    return self
  }
  
  public func build() -> TwilioVerify {
    let factorFacade = FactorFacade.Builder()
      .setNetworkProvider(networkProvider)
      .setKeyStorage(keyStorage)
      .setURL(baseURL)
      .setAuthentication(authentication)
      .build()
    return TwilioVerifyManager(factorFacade: factorFacade)
  }
}
