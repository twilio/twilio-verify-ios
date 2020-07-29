//
//  ChallengeAPIClient.swift
//  TwilioVerify
//
//  Created by Yeimi Moreno on 6/23/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol ChallengeAPIClientProtocol {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
  func getAll(forFactor factor: Factor, status: String?, pageSize: Int, pageToken: String?, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
  func update(_ challenge: FactorChallenge, withAuthPayload authPayload: String, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
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
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    do {
      let authToken = try authentication.generateJWT(forFactor: factor)
      let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: authToken))
      let request = try URLRequestBuilder(withURL: getChallengeURL(forSid: sid, forFactor: factor), requestHelper: requestHelper)
        .setHTTPMethod(.get)
        .build()
      networkProvider.execute(request, success: success, failure: failure)
    } catch {
      failure(error)
    }
  }
  
  func getAll(forFactor factor: Factor, status: String?, pageSize: Int, pageToken: String?, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    do {
      let authToken = try authentication.generateJWT(forFactor: factor)
      let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: authToken))
      var parameters = [Parameter(name: Constants.factorSidKey, value: factor.sid),
                        Parameter(name: Constants.pageSizeKey, value: pageSize)]
      if let status = status {
        parameters.append(Parameter(name: Constants.statusKey, value: status))
      }
      if let pageToken = pageToken {
        parameters.append(Parameter(name: Constants.pageTokenKey, value: pageToken))
      }
      let request = try URLRequestBuilder(withURL: getChallengesURL(forFactor: factor), requestHelper: requestHelper)
        .setParameters(parameters)
        .build()
      networkProvider.execute(request, success: success, failure: failure)
    } catch {
      failure(error)
    }
  }
  
  func update(_ challenge: FactorChallenge, withAuthPayload authPayload: String, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    do {
      guard let factor = challenge.factor else {
        failure(InputError.invalidInput)
        return
      }
      let authToken = try authentication.generateJWT(forFactor: factor)
      let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: authToken))
      let request = try URLRequestBuilder(withURL: updateChallengeURL(forSid: challenge.sid, forFactor: factor), requestHelper: requestHelper)
        .setHTTPMethod(.post)
        .setParameters(updateChallengeBody(authPayload: authPayload))
        .build()
      networkProvider.execute(request, success: success, failure: failure)
    } catch {
      failure(error)
    }
  }
}

private extension ChallengeAPIClient {
  func getChallengeURL(forSid sid: String, forFactor factor: Factor) -> String {
    "\(baseURL)\(Constants.getChallengeURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: factor.serviceSid)
      .replacingOccurrences(of: APIConstants.identityPath, with: factor.identity)
      .replacingOccurrences(of: APIConstants.challengeSidPath, with: sid)
  }
  
  func getChallengesURL(forFactor factor: Factor) -> String {
    "\(baseURL)\(Constants.getChallengesURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: factor.serviceSid)
      .replacingOccurrences(of: APIConstants.identityPath, with: factor.identity)
  }
  
  func updateChallengeURL(forSid sid: String, forFactor factor: Factor) -> String {
    "\(baseURL)\(Constants.updateChallengeURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: factor.serviceSid)
      .replacingOccurrences(of: APIConstants.identityPath, with: factor.identity)
      .replacingOccurrences(of: APIConstants.challengeSidPath, with: sid)
  }
  
  func updateChallengeBody(authPayload: String) -> [Parameter] {
    [Parameter(name: Constants.authPayloadKey, value: authPayload)]
  }
}

extension ChallengeAPIClient {
  struct Constants {
    static let authPayloadKey = "AuthPayload"
    static let pageSizeKey = "PageSize"
    static let pageTokenKey = "pageToken"
    static let statusKey = "Status"
    static let factorSidKey = "FactorSid"
    static let getChallengeURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.identityPath)/Challenges/\(APIConstants.challengeSidPath)"
    static let getChallengesURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.identityPath)/Challenges"
    static let updateChallengeURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.identityPath)/Challenges/\(APIConstants.challengeSidPath)"
  }
}
