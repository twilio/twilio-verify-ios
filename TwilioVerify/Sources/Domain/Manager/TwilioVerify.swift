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
public typealias FactorListSuccessBlock = ([Factor]) -> ()
public typealias EmptySuccessBlock = () -> ()

public protocol TwilioVerify {
  func createFactor(
    withPayload payload: FactorPayload,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )
  
  func verifyFactor(
    withPayload payload: VerifyFactorPayload,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  func updateFactor(
    withPayload payload: UpdateFactorPayload,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  func getAllFactors(
    success: @escaping FactorListSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  func deleteFactor(
    withSid sid: String,
    success: @escaping EmptySuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )
  
  func getChallenge(
    challengeSid: String,
    factorSid: String,
    success: @escaping ChallengeSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )

  func updateChallenge(
    withPayload payload: UpdateChallengePayload,
    success: @escaping EmptySuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  )
  
  func getAllChallenges(
    withPayload payload: ChallengeListPayload,
    success: @escaping (ChallengeList) -> (),
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
    guard let baseURL = Bundle(for: TwilioVerifyBuilder.self).object(forInfoDictionaryKey: Constants.baseURLKey) as? String else {
        return
    }
    self.baseURL = Constants.httpsPrefix + baseURL
  }
  
  func setNetworkProvider(_ networkProvider: NetworkProvider) -> Self {
    self.networkProvider = networkProvider
    return self
  }
  
  func setURL(_ url: String) -> Self {
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
    let challengeFacade = ChallengeFacade.Builder()
      .setNetworkProvider(networkProvider)
      .setJWTGenerator(jwtGenerator)
      .setURL(baseURL)
      .setAuthentication(authentication)
      .setFactorFacade(factorFacade)
      .build()
    return TwilioVerifyManager(factorFacade: factorFacade, challengeFacade: challengeFacade)
  }
}

private extension TwilioVerifyBuilder {
  struct Constants {
    static let baseURLKey = "BaseURL"
    static let httpsPrefix = "https://"
  }
}

