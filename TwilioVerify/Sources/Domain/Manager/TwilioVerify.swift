//
//  TwilioVerify.swift
//  TwilioVerify
//
//  Created by Santiago Avila on 6/18/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

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
    success: @escaping ([Factor]) -> (),
    failure: @escaping TwilioVerifyErrorBlock
  )

  func getChallenge(
    challengeSid: String,
    factorSid: String,
    success: @escaping (Challenge) -> (),
    failure: @escaping TwilioVerifyErrorBlock
  )

  func getAllChallenges(
    withInput input: ChallengeListInput,
    success: @escaping (ChallengeList) -> (),
    failure: @escaping TwilioVerifyErrorBlock
  )

  func updateChallenge(
    withInput input: UpdateChallengeInput,
    success: @escaping () -> (),
    failure: @escaping TwilioVerifyErrorBlock
  )

  func deleteFactor(
    withSid sid: String,
    success: @escaping () -> (),
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
    return TwilioVerifyManager(factorFacade: factorFacade)
  }
}

private extension TwilioVerifyBuilder {
  struct Constants {
    static let baseURLKey = "BaseURL"
    static let httpsPrefix = "https://"
  }
}

