//
//  ChallengeAPIClient.swift
//  TwilioVerify
//
//  Created by Yeimi Moreno on 6/23/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol ChallengeAPIClientProtocol {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping SuccessBlock, failure: @escaping FailureBlock)
}

class ChallengeAPIClient {
  private let networkProvider: NetworkProvider
  private let authentication: Authentication
  private let baseURL: String
  
  init(networkProvider: NetworkProvider = NetworkAdapter(), authentication: Authentication, baseURL: String) {
    self.networkProvider = networkProvider
    self.authentication = authentication
    self.baseURL = baseURL
  }
}

extension ChallengeAPIClient: ChallengeAPIClientProtocol {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
    do {
      let authToken = try authentication.generateJWT(forFactor: factor)
      let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: authToken))
      let request = try URLRequestBuilder(withURL: getChallengeURL(forSid: sid, forFactor: factor), requestHelper: requestHelper)
        .setHTTPMethod(.get)
        .build()
      networkProvider.execute(request, success: { response in
        success(response)
      }) { error in
        failure(error)
      }
    } catch {
      failure(error)
    }
  }
}

private extension ChallengeAPIClient {
  func getChallengeURL(forSid sid: String, forFactor factor: Factor) -> String {
    "\(baseURL)\(Constants.getChallengeURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: factor.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: factor.entityIdentity)
      .replacingOccurrences(of: APIConstants.challengeSidPath, with: sid)
  }
}

extension ChallengeAPIClient {
  struct Constants {
    static let getChallengeURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.entityPath)/Challenges/\(APIConstants.challengeSidPath)"
  }
}
