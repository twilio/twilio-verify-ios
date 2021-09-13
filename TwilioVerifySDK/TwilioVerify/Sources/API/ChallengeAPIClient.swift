//
//  ChallengeAPIClient.swift
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

protocol ChallengeAPIClientProtocol {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
  func getAll(forFactor factor: Factor, status: String?, pageSize: Int, order: ChallengeListOrder, pageToken: String?, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
  func update(_ challenge: FactorChallenge, withAuthPayload authPayload: String, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
}

class ChallengeAPIClient: BaseAPIClient {
  private let networkProvider: NetworkProvider
  private let authentication: Authentication
  private let baseURL: String
  
  init(networkProvider: NetworkProvider = NetworkAdapter(), authentication: Authentication, baseURL: String, dateProvider: DateProvider = DateAdapter()) {
    self.networkProvider = networkProvider
    self.authentication = authentication
    self.baseURL = baseURL
    super.init(dateProvider: dateProvider)
  }
}

extension ChallengeAPIClient: ChallengeAPIClientProtocol {
  func get(withSid sid: String, withFactor factor: Factor, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    func getChallenge(retries: Int = BaseAPIClient.Constants.retryTimes) {
      do {
        let authToken = try authentication.generateJWT(forFactor: factor)
        let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: authToken))
        let request = try URLRequestBuilder(withURL: getChallengeURL(forSid: sid, forFactor: factor), requestHelper: requestHelper)
          .setHTTPMethod(.get)
          .build()
        networkProvider.execute(request, success: success, failure: { error in
          self.validateFailureResponse(withError: error, retries: retries, retryBlock: getChallenge, failure: failure)
        })
      } catch {
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(error)
      }
    }
    getChallenge()
  }
  
  func getAll(forFactor factor: Factor, status: String?, pageSize: Int, order: ChallengeListOrder, pageToken: String?, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    func getAllChallenges(retries: Int = BaseAPIClient.Constants.retryTimes) {
      do {
        let authToken = try authentication.generateJWT(forFactor: factor)
        let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: authToken))
        var parameters = [Parameter(name: Constants.factorSidKey, value: factor.sid),
                          Parameter(name: Constants.pageSizeKey, value: pageSize),
                          Parameter(name: Constants.orderKey, value: order.rawValue)]
        if let status = status {
          parameters.append(Parameter(name: Constants.statusKey, value: status))
        }
        if let pageToken = pageToken {
          parameters.append(Parameter(name: Constants.pageTokenKey, value: pageToken))
        }
        let request = try URLRequestBuilder(withURL: getChallengesURL(forFactor: factor), requestHelper: requestHelper)
          .setParameters(parameters)
          .build()
        networkProvider.execute(request, success: success, failure: { error in
          self.validateFailureResponse(withError: error, retries: retries, retryBlock: getAllChallenges, failure: failure)
        })
      } catch {
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(error)
      }
    }
    getAllChallenges()
  }
  
  func update(_ challenge: FactorChallenge, withAuthPayload authPayload: String, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    func updateChallenge(retries: Int = BaseAPIClient.Constants.retryTimes) {
      do {
        guard let factor = challenge.factor else {
          failure(InputError.invalidInput(field: "factor for challenge"))
          return
        }
        let authToken = try authentication.generateJWT(forFactor: factor)
        let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: authToken))
        let request = try URLRequestBuilder(withURL: updateChallengeURL(forSid: challenge.sid, forFactor: factor), requestHelper: requestHelper)
          .setHTTPMethod(.post)
          .setParameters(updateChallengeBody(authPayload: authPayload))
          .build()
        networkProvider.execute(request, success: success, failure: { error in
          self.validateFailureResponse(withError: error, retries: retries, retryBlock: updateChallenge, failure: failure)
        })
      } catch {
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(error)
      }
    }
    updateChallenge()
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
    static let orderKey = "Order"
    static let statusKey = "Status"
    static let factorSidKey = "FactorSid"
    static let getChallengeURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.identityPath)/Challenges/\(APIConstants.challengeSidPath)"
    static let getChallengesURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.identityPath)/Challenges"
    static let updateChallengeURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.identityPath)/Challenges/\(APIConstants.challengeSidPath)"
  }
}
