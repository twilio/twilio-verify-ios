//
//  FactorAPIClient.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/4/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol FactorAPIClientProtocol {
  func create(withPayload payload: CreateFactorPayload, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
  func verify(_ factor: Factor, authPayload: String, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
  func delete(_ factor: Factor, success: @escaping EmptySuccessBlock, failure: @escaping FailureBlock)
  func update(_ factor: Factor, updateFactorDataPayload: UpdateFactorDataPayload, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock)
}

class FactorAPIClient {
  
  private let networkProvider: NetworkProvider
  private let authentication: Authentication
  private let baseURL: String
  
  init(networkProvider: NetworkProvider = NetworkAdapter(), authentication: Authentication, baseURL: String) {
    self.networkProvider = networkProvider
    self.authentication = authentication
    self.baseURL = baseURL
  }
}

extension FactorAPIClient: FactorAPIClientProtocol {
  func create(withPayload payload: CreateFactorPayload, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    do {
      let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: payload.jwe))
      let request = try URLRequestBuilder(withURL: createURL(createFactorPayload: payload), requestHelper: requestHelper)
        .setHTTPMethod(.post)
        .setParameters(createFactorBody(createFactorPayload: payload))
        .build()
      networkProvider.execute(request, success: success, failure: failure)
    } catch {
      failure(error)
    }
  }
  
  func verify(_ factor: Factor, authPayload: String, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    do {
      let authToken = try authentication.generateJWT(forFactor: factor)
      let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: authToken))
      let request = try URLRequestBuilder(withURL: verifyURL(for: factor), requestHelper: requestHelper)
        .setHTTPMethod(.post)
        .setParameters(verifyFactorBody(authPayload: authPayload))
        .build()
      networkProvider.execute(request, success: success, failure: failure)
    } catch {
      failure(error)
    }
  }
  
  func delete(_ factor: Factor, success: @escaping EmptySuccessBlock, failure: @escaping FailureBlock) {
    do {
      let authToken = try authentication.generateJWT(forFactor: factor)
      let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: authToken))
      let request = try URLRequestBuilder(withURL: deleteURL(for: factor), requestHelper: requestHelper)
        .setHTTPMethod(.delete)
        .build()
      networkProvider.execute(request, success: { _ in
        success()
      }, failure: failure)
    } catch {
      failure(error)
    }
  }
  
  func update(_ factor: Factor, updateFactorDataPayload: UpdateFactorDataPayload, success: @escaping SuccessResponseBlock, failure: @escaping FailureBlock) {
    do {
      let authToken = try authentication.generateJWT(forFactor: factor)
      let requestHelper = RequestHelper(authorization: BasicAuthorization(username: APIConstants.jwtAuthenticationUser, password: authToken))
      let request = try URLRequestBuilder(withURL: updateURL(for: factor), requestHelper: requestHelper)
        .setHTTPMethod(.post)
        .setParameters(updateFactorBody(updateFactorDataPayload: updateFactorDataPayload))
        .build()
      networkProvider.execute(request, success: success, failure: failure)
    } catch {
      failure(error)
    }
  }
}

private extension FactorAPIClient {
  func createURL(createFactorPayload: CreateFactorPayload) -> String {
    "\(baseURL)\(Constants.createFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: createFactorPayload.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: createFactorPayload.entity)
  }
  
  func createFactorBody(createFactorPayload: CreateFactorPayload) throws -> [Parameter] {
    guard let bindingData = try? JSONEncoder().encode(createFactorPayload.binding),
      let bindingString = String(data: bindingData, encoding: .utf8)  else {
        throw NetworkError.invalidData
    }
    
    guard let configData = try? JSONEncoder().encode(createFactorPayload.config),
      let configString = String(data: configData, encoding: .utf8) else {
        throw NetworkError.invalidData
    }
    
    return [Parameter(name: Constants.friendlyNameKey, value: createFactorPayload.friendlyName),
            Parameter(name: Constants.factorTypeKey, value: createFactorPayload.type.rawValue),
            Parameter(name: Constants.bindingKey, value: bindingString),
            Parameter(name: Constants.configKey, value: configString)]
  }
  
  func verifyURL(for factor: Factor) -> String {
    "\(baseURL)\(Constants.verifyFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: factor.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: factor.entityIdentity)
      .replacingOccurrences(of: APIConstants.factorSidPath, with: factor.sid)
  }
  
  func verifyFactorBody(authPayload: String) -> [Parameter] {
    [Parameter(name: Constants.authPayloadKey, value: authPayload)]
  }
  
  func deleteURL(for factor: Factor) -> String {
    "\(baseURL)\(Constants.deleteFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: factor.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: factor.entityIdentity)
      .replacingOccurrences(of: APIConstants.factorSidPath, with: factor.sid)
  }
  
  func updateURL(for factor: Factor) -> String {
    "\(baseURL)\(Constants.updateFactorURL)"
      .replacingOccurrences(of: APIConstants.serviceSidPath, with: factor.serviceSid)
      .replacingOccurrences(of: APIConstants.entityPath, with: factor.entityIdentity)
      .replacingOccurrences(of: APIConstants.factorSidPath, with: factor.sid)
  }
  
  func updateFactorBody(updateFactorDataPayload: UpdateFactorDataPayload) throws -> [Parameter] {
    guard let configData = try? JSONEncoder().encode(updateFactorDataPayload.config),
      let configString = String(data: configData, encoding: .utf8) else {
        throw NetworkError.invalidData
    }
    return [Parameter(name: Constants.friendlyNameKey, value: updateFactorDataPayload.friendlyName),
            Parameter(name: Constants.configKey, value: configString)]
  }
}

extension FactorAPIClient {
  struct Constants {
    static let friendlyNameKey = "FriendlyName"
    static let factorTypeKey = "FactorType"
    static let bindingKey = "Binding"
    static let configKey = "Config"
    static let authPayloadKey = "AuthPayload"
    static let createFactorURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.entityPath)/Factors"
    static let verifyFactorURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.entityPath)/Factors/\(APIConstants.factorSidPath)"
    static let deleteFactorURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.entityPath)/Factors/\(APIConstants.factorSidPath)"
    static let updateFactorURL = "Services/\(APIConstants.serviceSidPath)/Entities/\(APIConstants.entityPath)/Factors/\(APIConstants.factorSidPath)"
  }
}
